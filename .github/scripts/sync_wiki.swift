#!/usr/bin/env swift
//
// sync_wiki.swift — Mirror this repo's generated Markdown into its GitHub
// wiki (github.com/<owner>/<repo>/wiki), so the wiki reflects the same
// content as the repo itself.
//
// What it does:
//   * clones the wiki (a separate git repo at <owner>/<repo>.wiki.git),
//   * replaces its content with every *.md page and category folder from
//     this repo (skipping repo plumbing — this script, hig_download.swift,
//     CI config, git metadata),
//   * renames README.md to Home.md (the wiki's required landing-page name)
//     and rewrites every reference to it across all pages,
//   * builds _Sidebar.md from the "## Contents" tree already in Home.md,
//     since Gollum's default sidebar is just an alphabetical list of all
//     pages, which isn't navigable at this page count,
//   * commits and pushes only if something actually changed.
//
// Usage:
//     swift sync_wiki.swift <owner/repo>
//
// Auth: set GITHUB_TOKEN in the environment to push non-interactively
// (e.g. in CI); without it, the ambient `git`/`gh` credential helper is
// used, which is what a local run relies on.
//
// No third-party dependencies — Foundation only; shells out to `git`.

import Foundation

struct RuntimeError: Error, CustomStringConvertible {
    let message: String
    var description: String { message }
}

func die(_ message: String) -> Never {
    FileHandle.standardError.write((message + "\n").data(using: .utf8)!)
    exit(1)
}

/// Runs a command to completion, draining stdout/stderr concurrently on
/// background queues so a chatty child process (e.g. `git clone`'s
/// progress output) can never deadlock by filling a pipe buffer no one
/// is reading yet.
@discardableResult
func run(_ args: [String], cwd: String? = nil) throws -> String {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
    process.arguments = args
    if let cwd = cwd {
        process.currentDirectoryURL = URL(fileURLWithPath: cwd)
    }

    let stdoutPipe = Pipe()
    let stderrPipe = Pipe()
    process.standardOutput = stdoutPipe
    process.standardError = stderrPipe

    var stdoutData = Data()
    var stderrData = Data()
    let group = DispatchGroup()

    group.enter()
    DispatchQueue.global().async {
        stdoutData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
        group.leave()
    }
    group.enter()
    DispatchQueue.global().async {
        stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()
        group.leave()
    }

    try process.run()
    group.wait()
    process.waitUntilExit()

    let outStr = String(data: stdoutData, encoding: .utf8) ?? ""
    let errStr = String(data: stderrData, encoding: .utf8) ?? ""
    if process.terminationStatus != 0 {
        throw RuntimeError(message: "Command failed (\(process.terminationStatus)): \(args.joined(separator: " "))\n\(errStr)")
    }
    return outStr
}

func mdFiles(under dir: String) -> [String] {
    guard let enumerator = FileManager.default.enumerator(atPath: dir) else { return [] }
    var results: [String] = []
    for case let path as String in enumerator where path.hasSuffix(".md") {
        results.append(dir + "/" + path)
    }
    return results
}

/// Gollum (the wiki engine behind github.com/<repo>/wiki) routes pages by
/// filename alone — a page stored at "Components/Content/Charts.md" is
/// still served at .../wiki/Charts, not .../wiki/Components/Content/Charts.
/// The folder path is kept in the underlying git repo purely for our own
/// organization; it plays no part in Gollum's routing. So every link this
/// repo generates as a nested relative path (e.g.
/// "../../Foundations/Color.md") has to become just "Color" to work here.
/// Verified against the live wiki that both raw spaces and hyphens resolve
/// to the same page, so hyphens are used to avoid CommonMark's ambiguity
/// around unescaped spaces inside a bare `(...)` link destination.
func gollumPageName(fromRelativePath path: String) -> String {
    let decoded = path.removingPercentEncoding ?? path
    let basename = decoded.split(separator: "/").last.map(String.init) ?? decoded
    let withoutExt = basename.hasSuffix(".md") ? String(basename.dropLast(3)) : basename
    return withoutExt.replacingOccurrences(of: " ", with: "-")
}

/// Replaces every regex match's first capture group with `transform`'s
/// result, leaving the rest of `text` untouched.
func replacingCaptures(in text: String, matching pattern: String, _ transform: (String) -> String) -> String {
    guard let regex = try? NSRegularExpression(pattern: pattern) else { return text }
    let nsText = text as NSString
    let matches = regex.matches(in: text, range: NSRange(location: 0, length: nsText.length))
    guard !matches.isEmpty else { return text }
    var result = ""
    var lastEnd = 0
    for match in matches {
        let full = match.range
        let capture = match.range(at: 1)
        result += nsText.substring(with: NSRange(location: lastEnd, length: full.location - lastEnd))
        result += nsText.substring(with: NSRange(location: full.location, length: capture.location - full.location))
        result += transform(nsText.substring(with: capture))
        result += nsText.substring(with: NSRange(location: capture.location + capture.length, length: full.location + full.length - (capture.location + capture.length)))
        lastEnd = full.location + full.length
    }
    result += nsText.substring(from: lastEnd)
    return result
}

/// Rewrites every local page link — Markdown `](path/Page.md)` and the raw
/// HTML `href="path/Page.md"` used by card-grid thumbnails — to Gollum's
/// flat page-name form. Image URLs and external (http/https) links never
/// end in ".md", so they're untouched by construction.
func rewriteLinksForGollum(_ text: String) -> String {
    var result = replacingCaptures(in: text, matching: #"\]\(([^()\s]+\.md)\)"#) { gollumPageName(fromRelativePath: $0) }
    result = replacingCaptures(in: result, matching: #"href="([^"]+\.md)""#) { gollumPageName(fromRelativePath: $0) }
    return result
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

let cliArgs = CommandLine.arguments
guard cliArgs.count == 2 else {
    die("Usage: swift sync_wiki.swift <owner/repo>")
}
let repoSlug = cliArgs[1]

let token = ProcessInfo.processInfo.environment["GITHUB_TOKEN"]
let wikiURL: String = {
    if let token = token, !token.isEmpty {
        return "https://x-access-token:\(token)@github.com/\(repoSlug).wiki.git"
    }
    return "https://github.com/\(repoSlug).wiki.git"
}()

let fm = FileManager.default
let repoRoot = fm.currentDirectoryPath
let tmpDir = fm.temporaryDirectory.appendingPathComponent("wiki-sync-\(UUID().uuidString)").path
try fm.createDirectory(atPath: tmpDir, withIntermediateDirectories: true)
defer { try? fm.removeItem(atPath: tmpDir) }

print("Cloning wiki...")
do {
    try run(["git", "clone", "--depth", "1", wikiURL, "wiki"], cwd: tmpDir)
} catch {
    die("Couldn't clone the wiki repo. Is the wiki enabled for \(repoSlug)? \(error)")
}
let wikiDir = tmpDir + "/wiki"

// Clear existing wiki content (except .git) so deletions/renames in the
// source repo are reflected too.
for entry in try fm.contentsOfDirectory(atPath: wikiDir) where entry != ".git" {
    try fm.removeItem(atPath: wikiDir + "/" + entry)
}

// Mirror every generated content file/folder.
let categoryFolders = ["Components", "Foundations", "Getting started", "Inputs", "Patterns", "Technologies"]
let topLevelMarkdown = (try fm.contentsOfDirectory(atPath: repoRoot)).filter { $0.hasSuffix(".md") }
for entry in categoryFolders + topLevelMarkdown {
    let src = repoRoot + "/" + entry
    var isDir: ObjCBool = false
    guard fm.fileExists(atPath: src, isDirectory: &isDir) else { continue }
    try fm.copyItem(atPath: src, toPath: wikiDir + "/" + entry)
}

print("Rewriting README.md references to Home.md...")
for path in mdFiles(under: wikiDir) {
    let text = try String(contentsOfFile: path, encoding: .utf8)
    guard text.contains("README.md") else { continue }
    let rewritten = text.replacingOccurrences(of: "README.md", with: "Home.md")
    try rewritten.write(toFile: path, atomically: true, encoding: .utf8)
}
let readmePath = wikiDir + "/README.md"
if fm.fileExists(atPath: readmePath) {
    try fm.moveItem(atPath: readmePath, toPath: wikiDir + "/Home.md")
} else {
    die("Expected README.md at the repo root (run with --readme) — none found to seed Home.md.")
}

print("Building _Sidebar.md from the Contents tree...")
let homeText = try String(contentsOfFile: wikiDir + "/Home.md", encoding: .utf8)
guard let headingRange = homeText.range(of: "## Contents\n"),
      let dividerRange = homeText.range(of: "\n---\n", range: headingRange.upperBound..<homeText.endIndex) else {
    die("Couldn't find the \"## Contents\" tree in Home.md to build the sidebar from.")
}
let treeLines = homeText[headingRange.upperBound..<dividerRange.lowerBound]
    .split(separator: "\n", omittingEmptySubsequences: true)
    .map(String.init)
let sidebar = "**[Home](Home.md)**\n\n" + treeLines.joined(separator: "\n") + "\n"
try sidebar.write(toFile: wikiDir + "/_Sidebar.md", atomically: true, encoding: .utf8)

print("Rewriting internal links to Gollum's flat page-name routing...")
for path in mdFiles(under: wikiDir) {
    let text = try String(contentsOfFile: path, encoding: .utf8)
    let rewritten = rewriteLinksForGollum(text)
    if rewritten != text {
        try rewritten.write(toFile: path, atomically: true, encoding: .utf8)
    }
}

print("Committing...")
try run(["git", "add", "-A"], cwd: wikiDir)
let changed = try run(["git", "diff", "--cached", "--name-only"], cwd: wikiDir)
if changed.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
    print("Wiki already up to date.")
} else {
    try run(["git", "config", "user.name", "github-actions[bot]"], cwd: wikiDir)
    try run(["git", "config", "user.email", "github-actions[bot]@users.noreply.github.com"], cwd: wikiDir)
    let dateStr = String(ISO8601DateFormatter().string(from: Date()).prefix(10))
    try run(["git", "commit", "-m", "Sync wiki with repo content (\(dateStr))"], cwd: wikiDir)
    try run(["git", "push"], cwd: wikiDir)
    let fileCount = changed.split(separator: "\n").count
    print("Wiki updated: \(fileCount) file(s) changed.")
}
