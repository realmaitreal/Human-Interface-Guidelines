#!/usr/bin/env swift
//
// hig_download.swift — Download Apple's Human Interface Guidelines into local Markdown.
//
// The HIG is served by Apple's DocC documentation renderer, which exposes clean
// structured JSON for every page (no HTML scraping needed). This tool:
//
//   * crawls the navigation tree starting from the HIG landing page,
//   * converts each page's structured content into readable Markdown,
//   * mirrors the left-sidebar hierarchy as folders
//         e.g. output/Components/Layout and organization/Labels.md
//   * rewrites every internal link to a working *local* relative path,
//   * downloads every illustration locally into output/_assets and keeps Apple's
//     full descriptive ALT TEXT on each image (great for screen readers / AI agents),
//   * strips all site chrome (top nav, "supported platforms", the on-this-page
//     sidebar, sign-in, etc.) since none of that lives in the content JSON.
//
// Pages that point outside the HIG (e.g. SwiftUI / UIKit API docs) are linked to
// the live developer.apple.com URL, because they are not part of the HIG itself.
//
// Usage:
//     swift hig_download.swift [--out DIR] [--workers N] [--no-images]
//                               [--limit N] [--pages slug1,slug2,...]
//
//     --out DIR       Output directory (default: ./output)
//     --workers N     Parallel download workers (default: 8)
//     --images MODE   local=download files, remote=keep Apple CDN URLs, none=alt text only
//     --no-images     Alias for --images none
//     --readme        Name the landing page README.md (for a GitHub repo)
//     --limit N       Stop after crawling N pages (test)
//     --pages LIST    Only process these comma-separated slugs (e.g. "labels"),
//                     skipping tree discovery. Useful for spot-testing.
//
// No third-party dependencies — Foundation only.

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking  // URLSession lives here on Linux
#endif

let BASE = "https://developer.apple.com"
let DATA_PREFIX = "/tutorials/data"
let ROOT_URL = "/design/human-interface-guidelines"
let ROOT_SLUG = "human-interface-guidelines"
let HIG_PREFIX = "/design/human-interface-guidelines/"
let USER_AGENT = "Mozilla/5.0 (hig-download)"

typealias JSONDict = [String: Any]

struct Config: Sendable {
    var imgMode: String       // local | remote | none
    var readmeMode: Bool
    var rootFilename: String
}

// ---------------------------------------------------------------------------
// Small string / path helpers (posix-style, mirroring Python's os.path / posixpath)
// ---------------------------------------------------------------------------

func orDefault(_ s: String?, _ def: @autoclosure () -> String) -> String {
    (s?.isEmpty == false) ? s! : def()
}

func rstrip(_ s: String, _ chars: Set<Character>? = nil) -> String {
    var sub = Substring(s)
    if let chars = chars {
        while let last = sub.last, chars.contains(last) { sub.removeLast() }
    } else {
        while let last = sub.last, last.isWhitespace { sub.removeLast() }
    }
    return String(sub)
}

/// Trims exactly the characters Python's default `str.strip()` treats as
/// whitespace (Unicode White_Space). Unlike this, Foundation's
/// `CharacterSet.whitespacesAndNewlines` also matches U+200B ZERO WIDTH
/// SPACE and similar format characters, which would silently drop content
/// Apple's HIG text legitimately contains.
func strip(_ s: String) -> String {
    var sub = Substring(s)
    while let first = sub.first, first.isWhitespace { sub.removeFirst() }
    while let last = sub.last, last.isWhitespace { sub.removeLast() }
    return String(sub)
}

func pyCapitalize(_ s: String) -> String {
    guard !s.isEmpty else { return s }
    return s.prefix(1).uppercased() + s.dropFirst().lowercased()
}

func sanitize(_ name: String?) -> String {
    var s = name ?? ""
    s = s.replacingOccurrences(of: "/", with: "-")
    s = s.replacingOccurrences(of: "\\", with: "-")
    s = s.replacingOccurrences(of: ":", with: " -")
    s = s.replacingOccurrences(of: "\n", with: " ")
    s = strip(s)
    s = s.trimmingCharacters(in: CharacterSet(charactersIn: "."))
    s = strip(s)
    return s.isEmpty ? "untitled" : s
}

func slugOf(_ identifier: String) -> String {
    var s = identifier
    while s.hasSuffix("/") { s.removeLast() }
    let parts = s.split(separator: "/", omittingEmptySubsequences: false)
    return (parts.last.map(String.init) ?? s).lowercased()
}

let quoteAllowedChars: CharacterSet = CharacterSet(
    charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_.-~/#"
)

func encPath(_ path: String) -> String {
    path.addingPercentEncoding(withAllowedCharacters: quoteAllowedChars) ?? path
}

func pathJoin(_ parts: [String]) -> String {
    parts.filter { !$0.isEmpty }.joined(separator: "/")
}

/// POSIX-style relative path from `start` (a directory) to `target`.
func relPath(_ target: String, from start: String) -> String {
    let startParts = (start.isEmpty || start == ".") ? [] : start.split(separator: "/").map(String.init)
    let targetParts = target.split(separator: "/").map(String.init)
    var i = 0
    while i < startParts.count && i < targetParts.count && startParts[i] == targetParts[i] {
        i += 1
    }
    var result = Array(repeating: "..", count: startParts.count - i)
    result.append(contentsOf: targetParts[i...])
    return result.isEmpty ? "." : result.joined(separator: "/")
}

func dirnameOf(_ path: String) -> String {
    guard let idx = path.lastIndex(of: "/") else { return "" }
    return String(path[path.startIndex..<idx])
}

func fileExtension(of pathOrName: String) -> String {
    let filename: Substring
    if let slash = pathOrName.lastIndex(of: "/") {
        filename = pathOrName[pathOrName.index(after: slash)...]
    } else {
        filename = Substring(pathOrName)
    }
    guard let dot = filename.lastIndex(of: "."), dot != filename.startIndex else { return "" }
    return String(filename[dot...])
}

func urlPathComponent(_ urlString: String) -> String {
    URLComponents(string: urlString)?.path ?? urlString
}

func esc(_ text: String?) -> String {
    (text ?? "").replacingOccurrences(of: "|", with: "\\|")
}

func escAlt(_ text: String?) -> String {
    strip((text ?? "")
        .replacingOccurrences(of: "\n", with: " ")
        .replacingOccurrences(of: "[", with: "(")
        .replacingOccurrences(of: "]", with: ")"))
}

// ---------------------------------------------------------------------------
// JSON access helpers — JSONSerialization gives back [String: Any] / [Any],
// these mirror Python's dict.get(key, default) ergonomics.
// ---------------------------------------------------------------------------

func jStrOpt(_ d: JSONDict?, _ key: String) -> String? { d?[key] as? String }
func jStr(_ d: JSONDict?, _ key: String) -> String { (d?[key] as? String) ?? "" }
func jDict(_ d: JSONDict?, _ key: String) -> JSONDict { (d?[key] as? JSONDict) ?? [:] }
func jArr(_ d: JSONDict?, _ key: String) -> [Any] { (d?[key] as? [Any]) ?? [] }
func jDictArr(_ d: JSONDict?, _ key: String) -> [JSONDict] { jArr(d, key).compactMap { $0 as? JSONDict } }
func jStrArr(_ d: JSONDict?, _ key: String) -> [String] { jArr(d, key).compactMap { $0 as? String } }

func jInt(_ d: JSONDict?, _ key: String, _ def: Int = 0) -> Int {
    guard let v = d?[key] else { return def }
    if let i = v as? Int { return i }
    if let n = v as? NSNumber { return n.intValue }
    if let dd = v as? Double { return Int(dd) }
    return def
}

// ---------------------------------------------------------------------------
// Networking
// ---------------------------------------------------------------------------

struct FetchError: Error, CustomStringConvertible {
    let message: String
    var description: String { message }
}

func fetchRaw(_ urlString: String, retries: Int = 4) async throws -> Data {
    guard let url = URL(string: urlString) else {
        throw FetchError(message: "invalid URL: \(urlString)")
    }
    var lastError: Error = FetchError(message: "unknown error")
    for attempt in 0..<retries {
        do {
            var request = URLRequest(url: url)
            request.setValue(USER_AGENT, forHTTPHeaderField: "User-Agent")
            request.timeoutInterval = 45
            let (data, response) = try await URLSession.shared.data(for: request)
            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                throw FetchError(message: "HTTP \(http.statusCode) for \(urlString)")
            }
            return data
        } catch {
            lastError = error
            if attempt < retries - 1 {
                try? await Task.sleep(nanoseconds: UInt64(0.6 * Double(attempt + 1) * 1_000_000_000))
            }
        }
    }
    throw lastError
}

func dataUrl(for pageUrl: String) -> String {
    BASE + DATA_PREFIX + pageUrl + ".json"
}

/// Fetches a page's JSON as raw text (Sendable-safe) so it can cross a
/// TaskGroup boundary; parsing happens back on the sequential side.
func fetchPageText(_ pageUrl: String) async -> (String, String?) {
    do {
        let data = try await fetchRaw(dataUrl(for: pageUrl))
        guard let text = String(data: data, encoding: .utf8) else {
            throw FetchError(message: "non-utf8 response")
        }
        return (pageUrl, text)
    } catch {
        print("  ! failed page \(pageUrl): \(error)")
        return (pageUrl, nil)
    }
}

func parseJSON(_ text: String) -> JSONDict? {
    guard let data = text.data(using: .utf8) else { return nil }
    return try? JSONSerialization.jsonObject(with: data) as? JSONDict
}

/// Bounded-concurrency map, the async/await analogue of Python's
/// ThreadPoolExecutor(max_workers=workers).map(...).
func boundedMap<T: Sendable, R: Sendable>(
    _ items: [T],
    workers: Int,
    _ transform: @escaping @Sendable (T) async -> R
) async -> [R] {
    guard !items.isEmpty else { return [] }
    var results = [R?](repeating: nil, count: items.count)
    await withTaskGroup(of: (Int, R).self) { group in
        var nextIndex = 0
        func addNext() {
            guard nextIndex < items.count else { return }
            let i = nextIndex
            let item = items[i]
            nextIndex += 1
            group.addTask {
                let r = await transform(item)
                return (i, r)
            }
        }
        for _ in 0..<min(workers, items.count) { addNext() }
        while let (i, r) = await group.next() {
            results[i] = r
            addNext()
        }
    }
    return results.map { $0! }
}

// ---------------------------------------------------------------------------
// Rendering context
// ---------------------------------------------------------------------------

final class ImageStore {
    private var storage: [String: String] = [:]
    func set(_ key: String, _ value: String) { storage[key] = value }
    var all: [String: String] { storage }
    var count: Int { storage.count }
}

struct Context {
    let refs: JSONDict
    let pagePaths: [String: String]
    let titleMap: [String: String]
    let pagedir: String
    let images: ImageStore
    let cfg: Config
}

// ---------------------------------------------------------------------------
// Inline rendering
// ---------------------------------------------------------------------------

func renderInline(_ nodes: [Any]?, _ ctx: Context) -> String {
    guard let nodes = nodes, !nodes.isEmpty else { return "" }
    var out = ""
    for n in nodes {
        if let s = n as? String {
            out += esc(s)
            continue
        }
        guard let node = n as? JSONDict else { continue }
        switch jStrOpt(node, "type") {
        case "text":
            out += esc(jStr(node, "text"))
        case "emphasis":
            out += "*" + renderInline(jArr(node, "inlineContent"), ctx) + "*"
        case "strong":
            out += "**" + renderInline(jArr(node, "inlineContent"), ctx) + "**"
        case "codeVoice":
            out += "`" + jStr(node, "code") + "`"
        case "strikethrough":
            out += "~~" + renderInline(jArr(node, "inlineContent"), ctx) + "~~"
        case "reference":
            out += renderReference(jStrOpt(node, "identifier"), ctx)
        case "link":
            let inner = renderInline(jArr(node, "inlineContent"), ctx)
            let txt = orDefault(inner.isEmpty ? nil : inner, jStr(node, "title"))
            let ident = jStrOpt(node, "identifier")
            let identOrUrl = orDefault(ident, jStr(node, "url"))
            let url = localOrExternal(identOrUrl.isEmpty ? nil : identOrUrl, ctx, explicitUrl: jStrOpt(node, "url"))
            out += url.isEmpty ? txt : "[\(txt)](\(url))"
        case "image":
            out += renderImage(node, ctx)
        case "newTerm", "term":
            out += renderInline(jArr(node, "inlineContent"), ctx)
        default:
            if node["inlineContent"] != nil {
                out += renderInline(jArr(node, "inlineContent"), ctx)
            } else if let txt = jStrOpt(node, "text") {
                out += esc(txt)
            }
        }
    }
    return out
}

func refText(_ identifier: String, _ ctx: Context) -> String {
    let ref = jDict(ctx.refs, identifier)
    if let titleInline = ref["titleInlineContent"] as? [Any], !titleInline.isEmpty {
        return renderInline(titleInline, ctx)
    }
    if let title = jStrOpt(ref, "title"), !title.isEmpty {
        return esc(title)
    }
    return esc(slugOf(identifier).replacingOccurrences(of: "-", with: " "))
}

func renderReference(_ identifier: String?, _ ctx: Context) -> String {
    guard let identifier = identifier, !identifier.isEmpty else { return "" }
    let text = refText(identifier, ctx)
    let url = localOrExternal(identifier, ctx)
    return url.isEmpty ? text : "[\(text)](\(url))"
}

/// Resolves a reference/link identifier to a local relative path or a live URL.
func localOrExternal(_ identifier: String?, _ ctx: Context, explicitUrl: String? = nil) -> String {
    let ref: JSONDict = identifier.map { jDict(ctx.refs, $0) } ?? [:]
    let url = explicitUrl ?? jStrOpt(ref, "url")

    var slug: String? = nil
    if let ident = identifier, ident.contains("com.apple.HIG") {
        slug = slugOf(ident)
    } else if let url = url, url.contains(HIG_PREFIX) {
        slug = slugOf(url)
    } else if let ident = identifier, ident.hasPrefix("http"), ident.contains(HIG_PREFIX) {
        slug = slugOf(ident)
    }

    if let slug = slug, let path = ctx.pagePaths[slug] {
        return encPath(relPath(path, from: ctx.pagedir))
    }
    if let url = url {
        return url.hasPrefix("/") ? BASE + url : url
    }
    if let ident = identifier, ident.hasPrefix("http") {
        return ident
    }
    if let slug = slug {
        return "\(BASE)\(HIG_PREFIX)\(slug)"
    }
    return ""
}

func pickVariant(_ ref: JSONDict) -> String? {
    let variants = jDictArr(ref, "variants")
    guard !variants.isEmpty else { return nil }
    func score(_ v: JSONDict) -> Int {
        let traits = Set(jStrArr(v, "traits"))
        var s = 0
        if traits.contains("light") { s += 2 }
        if traits.contains("dark") { s -= 2 }
        if traits.contains("2x") { s += 1 }
        return s
    }
    return variants.max(by: { score($0) < score($1) }).flatMap { jStrOpt($0, "url") }
}

/// Resolves an image identifier to alt text plus a usable link (a fully
/// resolved Apple URL in remote mode, or a local `_assets/...` relative
/// path in local mode — registering it for download as a side effect).
/// `link` is nil when there's no usable image or `--images none` was set.
func resolveImageLink(_ identifier: String?, _ ctx: Context) -> (alt: String, link: String?) {
    let ref = identifier.map { jDict(ctx.refs, $0) } ?? [:]
    var url = pickVariant(ref)
    if let u = url, u.hasPrefix("/") {
        // Apple now returns root-relative paths (e.g. "/images/com.apple.HIG/x.png")
        // instead of full CDN URLs; they resolve under the tutorials host.
        url = BASE + "/tutorials" + u
    }
    var alt = escAlt(jStrOpt(ref, "alt") ?? "")
    if alt.isEmpty {
        alt = escAlt(slugOf(orDefault(identifier, "image")).replacingOccurrences(of: "-", with: " "))
    }

    guard ctx.cfg.imgMode != "none", let resolvedUrl = url else { return (alt, nil) }

    let link: String
    if ctx.cfg.imgMode == "remote" {
        link = resolvedUrl
    } else {  // local
        var fname = sanitize(identifier)
        if fileExtension(of: fname).isEmpty {
            var ext = fileExtension(of: urlPathComponent(resolvedUrl))
            if ext.isEmpty { ext = ".png" }
            fname += ext
        }
        ctx.images.set(fname, resolvedUrl)  // dedupe by filename
        link = encPath(relPath(pathJoin(["_assets", fname]), from: ctx.pagedir))
    }
    return (alt, link)
}

func renderImage(_ node: JSONDict, _ ctx: Context) -> String {
    let (alt, link) = resolveImageLink(jStrOpt(node, "identifier"), ctx)
    let metadata = jDict(node, "metadata")
    let capArr = metadata["abstract"] as? [Any]
    let captxt = (capArr?.isEmpty == false) ? strip(renderInline(capArr, ctx)) : ""

    func withCap(_ s: String) -> String {
        s + (captxt.isEmpty ? "" : "  \n*\(captxt)*")
    }

    // No usable image, or text-only mode: keep the description as a caption.
    guard let link = link else {
        return withCap("*[Image: \(alt)]*")
    }
    return withCap("![\(alt)](\(link))")
}

// ---------------------------------------------------------------------------
// Block rendering
// ---------------------------------------------------------------------------

func renderBlocks(_ blocks: [Any]?, _ ctx: Context) -> String {
    guard let blocks = blocks else { return "" }
    var out = ""
    for b in blocks {
        guard let block = b as? JSONDict else { continue }
        out += renderBlock(block, ctx)
    }
    return out
}

func renderBlock(_ b: JSONDict, _ ctx: Context) -> String {
    switch jStrOpt(b, "type") {
    case "paragraph":
        let txt = strip(renderInline(jArr(b, "inlineContent"), ctx))
        return txt.isEmpty ? "" : txt + "\n\n"
    case "heading":
        let lvl = min(max(jInt(b, "level", 2), 1), 6)
        return String(repeating: "#", count: lvl) + " " + strip(esc(jStr(b, "text"))) + "\n\n"
    case "unorderedList":
        return renderList(b, ctx, ordered: false)
    case "orderedList":
        return renderList(b, ctx, ordered: true)
    case "aside":
        return renderAside(b, ctx)
    case "table":
        return renderTable(b, ctx)
    case "row":
        return renderRow(b, ctx)
    case "links":
        return renderLinksBlock(b, ctx)
    case "codeListing":
        let code = jStrArr(b, "code").joined(separator: "\n")
        let syntax = jStrOpt(b, "syntax") ?? ""
        return "```\(syntax)\n\(code)\n```\n\n"
    case "termList":
        return renderTermList(b, ctx)
    default:
        // Fallbacks for any unanticipated block type.
        if b["inlineContent"] != nil {
            let txt = strip(renderInline(jArr(b, "inlineContent"), ctx))
            return txt.isEmpty ? "" : txt + "\n\n"
        }
        if b["content"] != nil {
            return renderBlocks(jArr(b, "content"), ctx)
        }
        return ""
    }
}

func renderList(_ b: JSONDict, _ ctx: Context, ordered: Bool) -> String {
    var lines: [String] = []
    for (i, item) in jDictArr(b, "items").enumerated() {
        let marker = ordered ? "\(i + 1). " : "- "
        let body = rstrip(renderBlocks(jArr(item, "content"), ctx), ["\n"])
        if body.isEmpty { continue }
        let seg = body.components(separatedBy: "\n")
        let indent = String(repeating: " ", count: marker.count)
        let first = marker + seg[0]
        let rest = seg.dropFirst().map { $0.isEmpty ? $0 : indent + $0 }.joined(separator: "\n")
        lines.append(rest.isEmpty ? first : first + "\n" + rest)
    }
    return lines.isEmpty ? "" : lines.joined(separator: "\n") + "\n\n"
}

func renderAside(_ b: JSONDict, _ ctx: Context) -> String {
    let styleOrNote = orDefault(jStrOpt(b, "style"), "note")
    let name = orDefault(jStrOpt(b, "name"), pyCapitalize(styleOrNote))
    let body = rstrip(renderBlocks(jArr(b, "content"), ctx))
    if body.isEmpty { return "" }
    let quoted = body.components(separatedBy: "\n").map { $0.isEmpty ? ">" : "> " + $0 }.joined(separator: "\n")
    return "> **\(esc(name))**\n>\n\(quoted)\n\n"
}

func renderRow(_ b: JSONDict, _ ctx: Context) -> String {
    let rawCols = jDictArr(b, "columns")
    let cols = rawCols.map { strip(renderBlocks(jArr($0, "content"), ctx)) }
    guard cols.contains(where: { !$0.isEmpty }) else { return "" }
    if rawCols.count <= 1 {
        return cols.filter { !$0.isEmpty }.joined(separator: "\n\n") + "\n\n"
    }
    // Multi-column layout (e.g. side-by-side principle cards, before/after
    // image comparisons): use an HTML table so columns render side by side
    // instead of stacking. A blank line right after <td> and before </td>
    // switches GitHub's Markdown renderer back into Markdown mode for the
    // cell content.
    let cells = cols.map { "<td>\n\n\($0)\n\n</td>" }.joined(separator: "\n")
    return "<table>\n<tr>\n\(cells)\n</tr>\n</table>\n\n"
}

func cellText(_ cellBlocks: [Any]?, _ ctx: Context) -> String {
    var parts: [String] = []
    for b in cellBlocks ?? [] {
        guard let block = b as? JSONDict else { continue }
        if jStrOpt(block, "type") == "paragraph" {
            parts.append(renderInline(jArr(block, "inlineContent"), ctx))
        } else {
            parts.append(renderBlock(block, ctx).replacingOccurrences(of: "\n", with: " "))
        }
    }
    let s = parts.map { strip($0) }.filter { !$0.isEmpty }.joined(separator: " ")
    return strip(s.replacingOccurrences(of: "|", with: "\\|"))
}

func renderTable(_ b: JSONDict, _ ctx: Context) -> String {
    let rows = jArr(b, "rows").compactMap { $0 as? [Any] }
    guard !rows.isEmpty else { return "" }
    let ncols = rows.map { $0.count }.max() ?? 0
    guard ncols > 0 else { return "" }
    let hasHeader = jStrOpt(b, "header") == "row"
    let head: [Any] = hasHeader ? rows[0] : (0..<ncols).map { _ in [Any]() as Any }
    let body = hasHeader ? Array(rows.dropFirst()) : rows

    func fmt(_ row: [Any]) -> String {
        var cells = row.map { cellText($0 as? [Any], ctx) }
        while cells.count < ncols { cells.append("") }
        return "| " + cells.joined(separator: " | ") + " |"
    }

    var out = [fmt(head), "| " + Array(repeating: "---", count: ncols).joined(separator: " | ") + " |"]
    out.append(contentsOf: body.map { fmt($0) })
    return out.joined(separator: "\n") + "\n\n"
}

/// Topic references carry their own tile thumbnail/icon (`images: [{type:
/// "card"|"icon", identifier: ...}]`), separate from the inline images used
/// in prose. Reuses renderImage so remote/local/none modes, alt text, and
/// dedup-by-filename all behave identically to any other image.
func htmlEscapeAttr(_ s: String) -> String {
    s.replacingOccurrences(of: "&", with: "&amp;")
     .replacingOccurrences(of: "\"", with: "&quot;")
     .replacingOccurrences(of: "<", with: "&lt;")
     .replacingOccurrences(of: ">", with: "&gt;")
}

/// A small clickable thumbnail for a links-block entry, e.g. `<a
/// href="page"><img src="..." width="64"></a>`. Kept as a single inline
/// HTML snippet (not Markdown image syntax split across lines) so it
/// renders identically as plain list-item content in every renderer —
/// GitHub, Xcode/Quick Look, VS Code, etc. — instead of depending on
/// lazy-continuation rules for multi-line list items, which parsers
/// handle inconsistently, and without an explicit size it can also blow
/// up to the image's native pixel dimensions in non-GitHub viewers.
func linkThumbnailHTML(_ ref: JSONDict, _ ctx: Context, pageUrl: String) -> String? {
    let images = jDictArr(ref, "images")
    guard !images.isEmpty else { return nil }
    let card = images.first { jStrOpt($0, "type") == "card" }
    let icon = images.first { jStrOpt($0, "type") == "icon" }
    guard let chosen = card ?? icon, let imgIdent = jStrOpt(chosen, "identifier") else { return nil }
    let (alt, link) = resolveImageLink(imgIdent, ctx)
    guard let link = link else { return nil }
    let img = "<img src=\"\(htmlEscapeAttr(link))\" alt=\"\(htmlEscapeAttr(alt))\" width=\"100%\">"
    return pageUrl.isEmpty ? img : "<a href=\"\(htmlEscapeAttr(pageUrl))\">\(img)</a>"
}

private let linkCardGridColumns = 3

/// Lays out thumbnailed entries as an HTML table grid, `columns` per row —
/// the closest plain-Markdown analogue of Apple's own tile grid (no CSS,
/// so no gradient tile backgrounds, but the side-by-side card shape reads
/// the same). Reuses the blank-line-after-<td> convention already used for
/// multi-column "row" blocks so titles/links/descriptions parse as normal
/// Markdown inside each cell.
func renderCardGrid(_ items: [(thumb: String?, title: String, desc: String)]) -> String {
    func cell(_ item: (thumb: String?, title: String, desc: String)) -> String {
        var content = item.thumb.map { "\($0)  \n" } ?? ""
        content += "**\(item.title)**"
        if !item.desc.isEmpty { content += "  \n\(item.desc)" }
        return "<td valign=\"top\">\n\n\(content)\n\n</td>"
    }
    var rows: [String] = []
    var i = 0
    while i < items.count {
        let chunk = items[i..<min(i + linkCardGridColumns, items.count)]
        rows.append("<tr>\n\(chunk.map(cell).joined(separator: "\n"))\n</tr>")
        i += linkCardGridColumns
    }
    return "<table>\n\(rows.joined(separator: "\n"))\n</table>\n\n"
}

func renderLinksBlock(_ b: JSONDict, _ ctx: Context) -> String {
    struct Item { let title: String; let desc: String; let thumb: String? }

    let parsed: [Item] = jStrArr(b, "items").map { ident in
        let ref = jDict(ctx.refs, ident)
        let text = orDefault(jStrOpt(ref, "title"), slugOf(ident).replacingOccurrences(of: "-", with: " "))
        let url = localOrExternal(ident, ctx)
        let title = url.isEmpty ? esc(text) : "[\(esc(text))](\(url))"
        var desc = ""
        if let abstract = ref["abstract"] as? [Any] {
            desc = strip(renderInline(abstract, ctx))
        }
        let thumb = linkThumbnailHTML(ref, ctx, pageUrl: url)
        return Item(title: title, desc: desc, thumb: thumb)
    }
    guard !parsed.isEmpty else { return "" }

    // Topic indexes (category pages, the root README) carry a thumbnail per
    // entry — lay those out as a card grid, closer to Apple's own tile
    // grid. Plain reference lists without thumbnails (e.g. "Videos") stay
    // a simple bullet list.
    if parsed.contains(where: { $0.thumb != nil }) {
        return renderCardGrid(parsed.map { ($0.thumb, $0.title, $0.desc) })
    }

    let lines = parsed.map { $0.desc.isEmpty ? "- \($0.title)" : "- \($0.title) — \($0.desc)" }
    return lines.joined(separator: "\n") + "\n\n"
}

func renderTermList(_ b: JSONDict, _ ctx: Context) -> String {
    var lines: [String] = []
    for item in jDictArr(b, "items") {
        let term = strip(renderInline(jArr(jDict(item, "term"), "inlineContent"), ctx))
        let definition = strip(renderBlocks(jArr(jDict(item, "definition"), "content"), ctx))
        if !term.isEmpty {
            lines.append("- **\(term)** — \(definition)")
        } else if !definition.isEmpty {
            lines.append("- \(definition)")
        }
    }
    return lines.isEmpty ? "" : lines.joined(separator: "\n") + "\n\n"
}

// ---------------------------------------------------------------------------
// Page model
// ---------------------------------------------------------------------------

func titleFor(_ identifier: String, _ titleMap: [String: String]) -> String {
    if let t = titleMap[identifier] { return t }
    let s = slugOf(identifier)
    if let t = titleMap[s] { return t }
    return pyCapitalize(s.replacingOccurrences(of: "-", with: " "))
}

func ancestorsAfterRoot(_ page: JSONDict) -> [String] {
    let paths = jArr(jDict(page, "hierarchy"), "paths").compactMap { $0 as? [Any] }
    guard let chainAny = paths.first else { return [] }
    let chain = chainAny.compactMap { $0 as? String }
    var idx = -1
    for (i, ident) in chain.enumerated() where ident.lowercased().hasSuffix("/human-interface-guidelines") {
        idx = i
    }
    return idx >= 0 ? Array(chain[(idx + 1)...]) : []
}

func computePath(_ pageUrl: String, _ page: JSONDict, _ titleMap: [String: String], _ cfg: Config) -> String {
    let metadata = jDict(page, "metadata")
    let title = orDefault(jStrOpt(metadata, "title"), slugOf(pageUrl).replacingOccurrences(of: "-", with: " "))
    if slugOf(pageUrl) == ROOT_SLUG {
        return cfg.rootFilename
    }
    let folders = ancestorsAfterRoot(page).map { sanitize(titleFor($0, titleMap)) }
    let fname = sanitize(title) + ".md"
    return folders.isEmpty ? fname : pathJoin(folders + [fname])
}

// ---------------------------------------------------------------------------
// Discovery / crawl
// ---------------------------------------------------------------------------

func childUrls(_ page: JSONDict) -> [String] {
    var urls: [String] = []
    var seen = Set<String>()
    let refs = jDict(page, "references")

    func add(_ identifier: String) {
        let ref = jDict(refs, identifier)
        let url = orDefault(jStrOpt(ref, "url"), "\(ROOT_URL)/\(slugOf(identifier))")
        if !seen.contains(url) && (url + "/").contains(HIG_PREFIX) {
            seen.insert(url)
            urls.append(url)
        }
    }

    for sec in jDictArr(page, "topicSections") {
        for ident in jStrArr(sec, "identifiers") { add(ident) }
    }
    if urls.isEmpty {
        for sec in jDictArr(page, "primaryContentSections") {
            for block in jDictArr(sec, "content") where jStrOpt(block, "type") == "links" {
                for ident in jStrArr(block, "items") { add(ident) }
            }
        }
    }
    return urls
}

func crawl(workers: Int, limit: Int) async -> ([String: JSONDict], [String: [String]]) {
    var pages: [String: JSONDict] = [:]
    var children: [String: [String]] = [:]
    var visited = Set<String>()
    var frontier = [ROOT_URL]

    while !frontier.isEmpty {
        let batch = frontier.filter { !visited.contains($0) }
        for u in batch { visited.insert(u) }
        let results = await boundedMap(batch, workers: workers) { await fetchPageText($0) }
        var next: [String] = []
        var reachedLimit = false
        for (url, textOpt) in results {
            guard let text = textOpt, let data = parseJSON(text) else { continue }
            pages[url] = data
            let kids = childUrls(data)
            children[url] = kids
            for k in kids where !visited.contains(k) { next.append(k) }
            if limit > 0 && pages.count >= limit {
                print("  reached --limit \(limit), stopping crawl")
                reachedLimit = true
                break
            }
        }
        if reachedLimit { return (pages, children) }
        var seen = Set<String>()
        frontier = []
        for u in next where !seen.contains(u) {
            seen.insert(u)
            frontier.append(u)
        }
        print("  crawled \(pages.count) pages...")
    }
    return (pages, children)
}

func fetchSpecific(slugs: [String], workers: Int) async -> ([String: JSONDict], [String: [String]]) {
    var urls = [ROOT_URL]
    for s in slugs {
        let trimmed = strip(s)
        if !trimmed.isEmpty { urls.append("\(ROOT_URL)/\(trimmed)") }
    }
    let results = await boundedMap(urls, workers: workers) { await fetchPageText($0) }
    var pages: [String: JSONDict] = [:]
    var children: [String: [String]] = [:]
    for (url, textOpt) in results {
        guard let text = textOpt, let data = parseJSON(text) else { continue }
        pages[url] = data
        children[url] = childUrls(data)
    }
    return (pages, children)
}

// ---------------------------------------------------------------------------
// Build maps & write output
// ---------------------------------------------------------------------------

func buildMaps(_ pages: [String: JSONDict], _ cfg: Config) -> ([String: String], [String: String]) {
    var titleMap: [String: String] = [:]
    for page in pages.values {
        for (ident, refAny) in jDict(page, "references") {
            guard let ref = refAny as? JSONDict, let title = jStrOpt(ref, "title"), !title.isEmpty else { continue }
            titleMap[ident] = title
            titleMap[slugOf(ident)] = title
        }
    }
    for (url, page) in pages {
        let ident = jStrOpt(jDict(page, "identifier"), "url")
        if let title = jStrOpt(jDict(page, "metadata"), "title"), !title.isEmpty {
            if let ident = ident { titleMap[ident] = title }
            titleMap[slugOf(url)] = title
        }
    }

    var pagePaths: [String: String] = [:]
    for (url, page) in pages {
        pagePaths[slugOf(url)] = computePath(url, page, titleMap, cfg)
    }
    return (titleMap, pagePaths)
}

func breadcrumb(_ pageUrl: String, _ page: JSONDict, _ titleMap: [String: String], _ pagePaths: [String: String], _ pagedir: String) -> String {
    if slugOf(pageUrl) == ROOT_SLUG { return "" }
    var parts: [String] = []
    if let rootPath = pagePaths[ROOT_SLUG] {
        parts.append("[Human Interface Guidelines](\(encPath(relPath(rootPath, from: pagedir))))")
    }
    for g in ancestorsAfterRoot(page) {
        let gslug = slugOf(g)
        let gtitle = titleFor(g, titleMap)
        if let gpath = pagePaths[gslug] {
            parts.append("[\(gtitle)](\(encPath(relPath(gpath, from: pagedir))))")
        } else {
            parts.append(gtitle)
        }
    }
    parts.append("**\(jStr(jDict(page, "metadata"), "title"))**")
    return parts.joined(separator: " › ")
}

func renderTree(
    _ url: String, _ children: [String: [String]], _ titleMap: [String: String],
    _ pagePaths: [String: String], _ pagedir: String, depth: Int, seen: inout Set<String>
) -> String {
    if seen.contains(url) { return "" }
    seen.insert(url)
    var lines: [String] = []
    for child in children[url] ?? [] {
        let cslug = slugOf(child)
        let ctitle = orDefault(titleMap[cslug], pyCapitalize(cslug.replacingOccurrences(of: "-", with: " ")))
        let link: String
        if let cpath = pagePaths[cslug] {
            link = "[\(ctitle)](\(encPath(relPath(cpath, from: pagedir))))"
        } else {
            link = ctitle
        }
        lines.append(String(repeating: "  ", count: depth) + "- \(link)")
        lines.append(renderTree(child, children, titleMap, pagePaths, pagedir, depth: depth + 1, seen: &seen))
    }
    return lines.filter { !$0.isEmpty }.joined(separator: "\n")
}

func renderPageMd(
    _ pageUrl: String, _ page: JSONDict, _ titleMap: [String: String], _ pagePaths: [String: String],
    _ children: [String: [String]], _ images: ImageStore, _ cfg: Config
) -> String? {
    guard let relpath = pagePaths[slugOf(pageUrl)] else { return nil }
    let pagedir = dirnameOf(relpath)
    let ctx = Context(refs: jDict(page, "references"), pagePaths: pagePaths, titleMap: titleMap, pagedir: pagedir, images: images, cfg: cfg)
    let metadata = jDict(page, "metadata")
    let title = orDefault(jStrOpt(metadata, "title"), slugOf(pageUrl))

    var md: [String] = []

    if slugOf(pageUrl) == ROOT_SLUG && cfg.readmeMode {
        md.append("<!-- Auto-generated from Apple's Human Interface Guidelines by "
                 + "hig_download.swift — do not edit by hand; this file is overwritten on each run. -->")
        md.append("")
    }

    let crumb = breadcrumb(pageUrl, page, titleMap, pagePaths, pagedir)
    if !crumb.isEmpty {
        md.append(crumb)
        md.append("")
    }

    md.append("# \(title)")
    md.append("")

    if let abstract = page["abstract"] as? [Any], !abstract.isEmpty {
        let a = strip(renderInline(abstract, ctx))
        if !a.isEmpty {
            md.append("*\(a)*")
            md.append("")
        }
    }

    let alert = jStrOpt(jDict(metadata, "customMetadata"), "alert-text")
    if let alert = alert, !alert.isEmpty {
        md.append("> **Note**\n>\n> \(esc(alert))")
        md.append("")
    }

    for sec in jDictArr(page, "primaryContentSections") where jStrOpt(sec, "kind") == "content" {
        md.append(rstrip(renderBlocks(jArr(sec, "content"), ctx)))
        md.append("")
    }

    // Root landing page gets the full contents tree.
    if slugOf(pageUrl) == ROOT_SLUG && !children.isEmpty {
        var seen = Set<String>()
        let tree = renderTree(pageUrl, children, titleMap, pagePaths, pagedir, depth: 0, seen: &seen)
        if !tree.isEmpty {
            md.append("## Contents")
            md.append("")
            md.append(tree)
            md.append("")
        }
    }

    md.append("---")
    md.append("*Source: [\(BASE)\(pageUrl)](\(BASE)\(pageUrl))*")
    return rstrip(md.joined(separator: "\n")) + "\n"
}

// ---------------------------------------------------------------------------
// Image download
// ---------------------------------------------------------------------------

actor ProgressCounter {
    private var n = 0
    func increment() -> Int { n += 1; return n }
}

func downloadOneImage(fname: String, url: String, dest: String) async -> Bool {
    do {
        let data = try await fetchRaw(url)
        try data.write(to: URL(fileURLWithPath: dest))
        return true
    } catch {
        print("  ! image fail \(fname): \(error)")
        return false
    }
}

func downloadImages(_ images: [String: String], outDir: String, workers: Int) async {
    let assets = (outDir as NSString).appendingPathComponent("_assets")
    try? FileManager.default.createDirectory(atPath: assets, withIntermediateDirectories: true)

    var todo: [(String, String, String)] = []
    for (fname, url) in images {
        let dest = (assets as NSString).appendingPathComponent(fname)
        if let attrs = try? FileManager.default.attributesOfItem(atPath: dest),
           let size = attrs[.size] as? Int, size > 0 {
            continue
        }
        todo.append((fname, url, dest))
    }
    if todo.isEmpty {
        print("  images: all \(images.count) already present")
        return
    }

    let counter = ProgressCounter()
    let total = todo.count
    let results = await boundedMap(todo, workers: workers) { job -> Bool in
        let ok = await downloadOneImage(fname: job.0, url: job.1, dest: job.2)
        if ok {
            let n = await counter.increment()
            if n % 25 == 0 { print("  images: \(n)/\(total)") }
        }
        return ok
    }
    let successCount = results.filter { $0 }.count
    print("  images: downloaded \(successCount), failed \(results.count - successCount), total refs \(images.count)")
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

struct CLIArgs {
    var out = "output"
    var workers = 8
    var images = "local"
    var noImages = false
    var readme = false
    var limit = 0
    var pages = ""
}

func printUsage() {
    print("""
    Usage: swift hig_download.swift [--out DIR] [--workers N] [--images local|remote|none]
                                     [--no-images] [--readme] [--limit N] [--pages slug1,slug2,...]

      --out DIR       Output directory (default: ./output)
      --workers N     Parallel download workers (default: 8)
      --images MODE   local=download files, remote=keep Apple CDN URLs, none=alt text only
      --no-images     Alias for --images none
      --readme        Name the landing page README.md (for a GitHub repo)
      --limit N       Stop after crawling N pages (test)
      --pages LIST    Only process these comma-separated slugs, skipping tree discovery
    """)
}

func parseArgs(_ argv: [String]) -> CLIArgs {
    var a = CLIArgs()
    var i = 0
    func die(_ msg: String) -> Never {
        FileHandle.standardError.write((msg + "\n").data(using: .utf8)!)
        exit(1)
    }
    while i < argv.count {
        let raw = argv[i]
        var flag = raw
        var inline: String? = nil
        if raw.hasPrefix("--"), let eq = raw.firstIndex(of: "=") {
            flag = String(raw[raw.startIndex..<eq])
            inline = String(raw[raw.index(after: eq)...])
        }
        func value() -> String {
            if let inline = inline { return inline }
            i += 1
            guard i < argv.count else { die("Missing value for \(flag)") }
            return argv[i]
        }
        switch flag {
        case "--out": a.out = value()
        case "--workers": a.workers = Int(value()) ?? 8
        case "--images": a.images = value()
        case "--no-images": a.noImages = true
        case "--readme": a.readme = true
        case "--limit": a.limit = Int(value()) ?? 0
        case "--pages": a.pages = value()
        case "-h", "--help": printUsage(); exit(0)
        default: die("Unknown argument: \(raw)")
        }
        i += 1
    }
    return a
}

func mainAsync() async {
    let args = parseArgs(Array(CommandLine.arguments.dropFirst()))
    let cfg = Config(
        imgMode: args.noImages ? "none" : args.images,
        readmeMode: args.readme,
        rootFilename: args.readme ? "README.md" : "human-interface-guidelines.md"
    )

    let resolvedOutDir = URL(fileURLWithPath: args.out).standardizedFileURL.path
    try? FileManager.default.createDirectory(atPath: resolvedOutDir, withIntermediateDirectories: true)

    let t0 = Date()
    var pages: [String: JSONDict] = [:]
    var children: [String: [String]] = [:]

    if !args.pages.isEmpty {
        print("Fetching specific pages: \(args.pages)")
        let slugs = args.pages.split(separator: ",").map(String.init)
        (pages, children) = await fetchSpecific(slugs: slugs, workers: args.workers)
    } else {
        print("Crawling HIG navigation tree...")
        (pages, children) = await crawl(workers: args.workers, limit: args.limit)
    }
    print("Discovered \(pages.count) pages in \(String(format: "%.1f", Date().timeIntervalSince(t0)))s")

    let (titleMap, pagePaths) = buildMaps(pages, cfg)

    print("Rendering Markdown...")
    let images = ImageStore()
    var written = 0
    for (url, page) in pages {
        guard let md = renderPageMd(url, page, titleMap, pagePaths, children, images, cfg),
              let relpath = pagePaths[slugOf(url)] else { continue }
        let dest = (resolvedOutDir as NSString).appendingPathComponent(relpath)
        let destDir = (dest as NSString).deletingLastPathComponent
        try? FileManager.default.createDirectory(atPath: destDir.isEmpty ? resolvedOutDir : destDir, withIntermediateDirectories: true)
        do {
            try md.write(toFile: dest, atomically: true, encoding: .utf8)
            written += 1
        } catch {
            print("  ! write fail \(url): \(error)")
        }
    }
    print("Wrote \(written) markdown files")
    print("Referenced \(images.count) unique images")

    switch cfg.imgMode {
    case "local":
        print("Downloading images...")
        await downloadImages(images.all, outDir: resolvedOutDir, workers: args.workers)
    case "remote":
        print("Images: using remote Apple CDN URLs (nothing downloaded)")
    default:
        print("Images: alt-text only (nothing downloaded)")
    }

    print("DONE in \(String(format: "%.1f", Date().timeIntervalSince(t0)))s -> \(resolvedOutDir)")
}

await mainAsync()
