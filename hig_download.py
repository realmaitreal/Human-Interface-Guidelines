#!/usr/bin/env python3
"""
hig_download.py — Download Apple's Human Interface Guidelines into local Markdown.

The HIG is served by Apple's DocC documentation renderer, which exposes clean
structured JSON for every page (no HTML scraping needed). This tool:

  * crawls the navigation tree starting from the HIG landing page,
  * converts each page's structured content into readable Markdown,
  * mirrors the left-sidebar hierarchy as folders
        e.g. output/Components/Layout and organization/Labels.md
  * rewrites every internal link to a working *local* relative path,
  * downloads every illustration locally into output/_assets and keeps Apple's
    full descriptive ALT TEXT on each image (great for screen readers / AI agents),
  * strips all site chrome (top nav, "supported platforms", the on-this-page
    sidebar, sign-in, etc.) since none of that lives in the content JSON.

Pages that point outside the HIG (e.g. SwiftUI / UIKit API docs) are linked to
the live developer.apple.com URL, because they are not part of the HIG itself.

Usage:
    python3 hig_download.py [--out DIR] [--workers N] [--no-images]
                            [--limit N] [--pages slug1,slug2,...]

    --out DIR       Output directory (default: ./output)
    --workers N     Parallel download workers (default: 8)
    --no-images     Skip downloading illustrations (keeps alt text only)
    --limit N       Stop after crawling N pages (for quick tests)
    --pages LIST    Only process these comma-separated slugs (e.g. "labels"),
                    skipping tree discovery. Useful for spot-testing.

No third-party dependencies — standard library only.
"""

import argparse
import concurrent.futures as cf
import json
import os
import posixpath
import sys
import time
import urllib.parse
import urllib.request

BASE = "https://developer.apple.com"
DATA_PREFIX = "/tutorials/data"
ROOT_URL = "/design/human-interface-guidelines"
ROOT_SLUG = "human-interface-guidelines"
HIG_PREFIX = "/design/human-interface-guidelines/"
UA = {"User-Agent": "Mozilla/5.0 (hig-download)"}

# Set from CLI flags in main().
ROOT_FILENAME = "human-interface-guidelines.md"  # or README.md with --readme
IMG_MODE = "local"                                # local | remote | none
README_MODE = False

# ---------------------------------------------------------------------------
# Networking
# ---------------------------------------------------------------------------

def _fetch(url, binary=False, retries=4):
    last = None
    for attempt in range(retries):
        try:
            req = urllib.request.Request(url, headers=UA)
            with urllib.request.urlopen(req, timeout=45) as r:
                data = r.read()
                return data if binary else data.decode("utf-8")
        except Exception as e:  # noqa: BLE001
            last = e
            time.sleep(0.6 * (attempt + 1))
    raise last


def data_url_for(page_url):
    """Map a page url (/design/human-interface-guidelines/labels) to its JSON url."""
    return BASE + DATA_PREFIX + page_url + ".json"


def fetch_page(page_url):
    try:
        return page_url, json.loads(_fetch(data_url_for(page_url)))
    except Exception as e:  # noqa: BLE001
        print(f"  ! failed page {page_url}: {e}", flush=True)
        return page_url, None


# ---------------------------------------------------------------------------
# Small helpers
# ---------------------------------------------------------------------------

def sanitize(name):
    name = (name or "").replace("/", "-").replace("\\", "-").replace(":", " -")
    name = name.replace("\n", " ").strip().strip(".").strip()
    return name or "untitled"


def slug_of(identifier):
    return identifier.rstrip("/").split("/")[-1].lower()


def enc(relpath):
    """Percent-encode a relative path for a Markdown link, preserving slashes."""
    return urllib.parse.quote(relpath, safe="/#")


def rel(target, pagedir):
    """POSIX relative path from the directory of the current page to target."""
    start = pagedir if pagedir else "."
    return posixpath.relpath(target, start)


def esc(text):
    """Minimal inline escaping so prose never breaks Markdown structure."""
    return (text or "").replace("|", "\\|")


def esc_alt(text):
    """Sanitize alt text so brackets/newlines can't break ![]() syntax."""
    return (text or "").replace("\n", " ").replace("[", "(").replace("]", ")").strip()


# ---------------------------------------------------------------------------
# Inline rendering
# ---------------------------------------------------------------------------

def render_inline(nodes, ctx):
    if not nodes:
        return ""
    out = []
    for n in nodes:
        if isinstance(n, str):
            out.append(esc(n))
            continue
        t = n.get("type")
        if t == "text":
            out.append(esc(n.get("text", "")))
        elif t == "emphasis":
            out.append("*" + render_inline(n.get("inlineContent", []), ctx) + "*")
        elif t == "strong":
            out.append("**" + render_inline(n.get("inlineContent", []), ctx) + "**")
        elif t == "codeVoice":
            out.append("`" + n.get("code", "") + "`")
        elif t == "strikethrough":
            out.append("~~" + render_inline(n.get("inlineContent", []), ctx) + "~~")
        elif t == "reference":
            out.append(render_reference(n.get("identifier"), ctx))
        elif t == "link":
            txt = render_inline(n.get("inlineContent", []), ctx) or n.get("title", "")
            url = local_or_external(n.get("identifier") or n.get("url"), ctx, n.get("url"))
            out.append(f"[{txt}]({url})" if url else txt)
        elif t == "image":
            out.append(render_image(n, ctx))
        elif t == "newTerm" or t == "term":
            out.append(render_inline(n.get("inlineContent", []), ctx))
        else:
            if "inlineContent" in n:
                out.append(render_inline(n["inlineContent"], ctx))
            elif "text" in n:
                out.append(esc(n["text"]))
    return "".join(out)


def ref_text(identifier, ctx):
    ref = ctx["refs"].get(identifier, {})
    if ref.get("titleInlineContent"):
        return render_inline(ref["titleInlineContent"], ctx)
    if ref.get("title"):
        return esc(ref["title"])
    return esc(slug_of(identifier).replace("-", " "))


def render_reference(identifier, ctx):
    if not identifier:
        return ""
    text = ref_text(identifier, ctx)
    url = local_or_external(identifier, ctx)
    return f"[{text}]({url})" if url else text


def local_or_external(identifier, ctx, explicit_url=None):
    """Resolve a reference/link identifier to a local relative path or live URL."""
    ref = ctx["refs"].get(identifier, {}) if identifier else {}
    url = explicit_url or ref.get("url")

    slug = None
    if isinstance(identifier, str) and "com.apple.HIG" in identifier:
        slug = slug_of(identifier)
    elif url and HIG_PREFIX in url:
        slug = slug_of(url)
    elif isinstance(identifier, str) and identifier.startswith("http") and HIG_PREFIX in identifier:
        slug = slug_of(identifier)

    if slug and slug in ctx["page_paths"]:
        return enc(rel(ctx["page_paths"][slug], ctx["pagedir"]))

    if url:
        return BASE + url if url.startswith("/") else url
    if isinstance(identifier, str) and identifier.startswith("http"):
        return identifier
    if slug:
        return f"{BASE}{HIG_PREFIX}{slug}"
    return ""


def pick_variant(ref):
    variants = ref.get("variants", [])
    if not variants:
        return None

    def score(v):
        traits = set(v.get("traits", []))
        s = 0
        if "light" in traits:
            s += 2
        if "dark" in traits:
            s -= 2
        if "2x" in traits:
            s += 1
        return s

    return max(variants, key=score).get("url")


def render_image(node, ctx):
    ident = node.get("identifier")
    ref = ctx["refs"].get(ident, {})
    url = pick_variant(ref)
    alt = esc_alt(ref.get("alt", "")) or esc_alt(slug_of(ident or "image").replace("-", " "))
    cap = node.get("metadata", {}).get("abstract")
    captxt = render_inline(cap, ctx).strip() if cap else ""

    def with_cap(s):
        return s + (f"  \n*{captxt}*" if captxt else "")

    # No usable image, or text-only mode: keep the description as a caption.
    if IMG_MODE == "none" or not url:
        return with_cap(f"*[Image: {alt}]*")

    if IMG_MODE == "remote":
        link = url  # Apple CDN URL, already encoded
    else:  # local
        fname = sanitize(ident)
        if not os.path.splitext(fname)[1]:
            ext = os.path.splitext(urllib.parse.urlparse(url).path)[1] or ".png"
            fname += ext
        ctx["images"][fname] = url  # dedupe by filename
        link = enc(rel(posixpath.join("_assets", fname), ctx["pagedir"]))
    return with_cap(f"![{alt}]({link})")


# ---------------------------------------------------------------------------
# Block rendering
# ---------------------------------------------------------------------------

def render_blocks(blocks, ctx):
    parts = []
    for b in blocks or []:
        parts.append(render_block(b, ctx))
    return "".join(parts)


def render_block(b, ctx):
    t = b.get("type")
    if t == "paragraph":
        txt = render_inline(b.get("inlineContent", []), ctx).strip()
        return txt + "\n\n" if txt else ""
    if t == "heading":
        lvl = min(max(int(b.get("level", 2)), 1), 6)
        return "#" * lvl + " " + esc(b.get("text", "")).strip() + "\n\n"
    if t == "unorderedList":
        return render_list(b, ctx, ordered=False)
    if t == "orderedList":
        return render_list(b, ctx, ordered=True)
    if t == "aside":
        return render_aside(b, ctx)
    if t == "table":
        return render_table(b, ctx)
    if t == "row":
        return render_row(b, ctx)
    if t == "links":
        return render_links_block(b, ctx)
    if t == "codeListing":
        code = "\n".join(b.get("code", []))
        return f"```{b.get('syntax') or ''}\n{code}\n```\n\n"
    if t == "termList":
        return render_term_list(b, ctx)
    # Fallbacks for any unanticipated block type.
    if "inlineContent" in b:
        txt = render_inline(b["inlineContent"], ctx).strip()
        return txt + "\n\n" if txt else ""
    if "content" in b:
        return render_blocks(b["content"], ctx)
    return ""


def render_list(b, ctx, ordered):
    lines = []
    for i, item in enumerate(b.get("items", [])):
        marker = f"{i + 1}. " if ordered else "- "
        body = render_blocks(item.get("content", []), ctx).rstrip("\n")
        if not body:
            continue
        seg = body.split("\n")
        indent = " " * len(marker)
        first = marker + seg[0]
        rest = "\n".join((indent + ln if ln else ln) for ln in seg[1:])
        lines.append(first + ("\n" + rest if rest else ""))
    return "\n".join(lines) + "\n\n" if lines else ""


def render_aside(b, ctx):
    name = b.get("name") or (b.get("style", "note") or "note").capitalize()
    body = render_blocks(b.get("content", []), ctx).rstrip()
    if not body:
        return ""
    quoted = "\n".join(("> " + ln) if ln else ">" for ln in body.split("\n"))
    return f"> **{esc(name)}**\n>\n{quoted}\n\n"


def render_row(b, ctx):
    cols = []
    for col in b.get("columns", []):
        c = render_blocks(col.get("content", []), ctx).rstrip()
        if c:
            cols.append(c)
    return "\n\n".join(cols) + "\n\n" if cols else ""


def _cell(cellblocks, ctx):
    parts = []
    for b in cellblocks or []:
        if b.get("type") == "paragraph":
            parts.append(render_inline(b.get("inlineContent", []), ctx))
        else:
            parts.append(render_block(b, ctx).replace("\n", " "))
    s = " ".join(p.strip() for p in parts if p.strip())
    return s.replace("|", "\\|").strip()


def render_table(b, ctx):
    rows = b.get("rows", [])
    if not rows:
        return ""
    ncols = max((len(r) for r in rows), default=0)
    if ncols == 0:
        return ""
    has_header = b.get("header") == "row"
    head = rows[0] if has_header else [""] * ncols
    body = rows[1:] if has_header else rows

    def fmt(row):
        cells = [_cell(c, ctx) for c in row]
        cells += [""] * (ncols - len(cells))
        return "| " + " | ".join(cells) + " |"

    out = [fmt(head), "| " + " | ".join(["---"] * ncols) + " |"]
    out += [fmt(r) for r in body]
    return "\n".join(out) + "\n\n"


def render_links_block(b, ctx):
    lines = []
    for ident in b.get("items", []):
        ref = ctx["refs"].get(ident, {})
        text = ref.get("title") or slug_of(ident).replace("-", " ")
        url = local_or_external(ident, ctx)
        line = f"- [{esc(text)}]({url})" if url else f"- {esc(text)}"
        abstract = ref.get("abstract")
        if abstract:
            a = render_inline(abstract, ctx).strip()
            if a:
                line += f" — {a}"
        lines.append(line)
    return "\n".join(lines) + "\n\n" if lines else ""


def render_term_list(b, ctx):
    lines = []
    for item in b.get("items", []):
        term = render_inline(item.get("term", {}).get("inlineContent", []), ctx).strip()
        definition = render_blocks(item.get("definition", {}).get("content", []), ctx).strip()
        if term:
            lines.append(f"- **{term}** — {definition}")
        elif definition:
            lines.append(f"- {definition}")
    return "\n".join(lines) + "\n\n" if lines else ""


# ---------------------------------------------------------------------------
# Page model
# ---------------------------------------------------------------------------

def title_for(identifier, title_map):
    if identifier in title_map:
        return title_map[identifier]
    s = slug_of(identifier)
    if s in title_map:
        return title_map[s]
    return s.replace("-", " ").capitalize()


def ancestors_after_root(page):
    paths = page.get("hierarchy", {}).get("paths", [])
    if not paths:
        return []
    chain = paths[0]
    idx = -1
    for i, ident in enumerate(chain):
        if ident.lower().endswith("/human-interface-guidelines"):
            idx = i
    return chain[idx + 1:] if idx >= 0 else []


def compute_path(page_url, page, title_map):
    title = page.get("metadata", {}).get("title") or slug_of(page_url).replace("-", " ")
    if slug_of(page_url) == ROOT_SLUG:
        return ROOT_FILENAME
    folders = [sanitize(title_for(g, title_map)) for g in ancestors_after_root(page)]
    fname = sanitize(title) + ".md"
    return posixpath.join(*(folders + [fname])) if folders else fname


# ---------------------------------------------------------------------------
# Discovery / crawl
# ---------------------------------------------------------------------------

def child_urls(page):
    urls, seen = [], set()

    def add(identifier, refs):
        ref = refs.get(identifier, {})
        url = ref.get("url")
        if not url:
            url = f"{ROOT_URL}/{slug_of(identifier)}"
        if url not in seen and HIG_PREFIX in url + "/":
            seen.add(url)
            urls.append(url)

    refs = page.get("references", {})
    for sec in page.get("topicSections", []) or []:
        for ident in sec.get("identifiers", []):
            add(ident, refs)
    if not urls:
        for sec in page.get("primaryContentSections", []) or []:
            for block in sec.get("content", []) or []:
                if block.get("type") == "links":
                    for ident in block.get("items", []):
                        add(ident, refs)
    return urls


def crawl(workers, limit):
    pages = {}            # page_url -> json
    children = {}         # page_url -> [child_url] (discovery order)
    visited = set()
    frontier = [ROOT_URL]
    pool = cf.ThreadPoolExecutor(max_workers=workers)
    try:
        while frontier:
            batch = [u for u in frontier if u not in visited]
            for u in batch:
                visited.add(u)
            results = list(pool.map(fetch_page, batch))
            nxt = []
            for url, data in results:
                if data is None:
                    continue
                pages[url] = data
                kids = child_urls(data)
                children[url] = kids
                for k in kids:
                    if k not in visited:
                        nxt.append(k)
                if limit and len(pages) >= limit:
                    print(f"  reached --limit {limit}, stopping crawl", flush=True)
                    return pages, children
            # de-dup preserving order
            seen, frontier = set(), []
            for u in nxt:
                if u not in seen:
                    seen.add(u)
                    frontier.append(u)
            print(f"  crawled {len(pages)} pages...", flush=True)
    finally:
        pool.shutdown(wait=True)
    return pages, children


def fetch_specific(slugs, workers):
    urls = [ROOT_URL] + [f"{ROOT_URL}/{s.strip()}" for s in slugs if s.strip()]
    pages, children = {}, {}
    pool = cf.ThreadPoolExecutor(max_workers=workers)
    try:
        for url, data in pool.map(fetch_page, urls):
            if data is not None:
                pages[url] = data
                children[url] = child_urls(data)
    finally:
        pool.shutdown(wait=True)
    return pages, children


# ---------------------------------------------------------------------------
# Build maps & write output
# ---------------------------------------------------------------------------

def build_maps(pages):
    title_map = {}
    for page in pages.values():
        for ident, ref in page.get("references", {}).items():
            if ref.get("title"):
                title_map[ident] = ref["title"]
                title_map[slug_of(ident)] = ref["title"]
    for url, page in pages.items():
        ident = page.get("identifier", {}).get("url")
        title = page.get("metadata", {}).get("title")
        if title:
            if ident:
                title_map[ident] = title
            title_map[slug_of(url)] = title

    page_paths = {}  # slug -> relative file path
    for url, page in pages.items():
        page_paths[slug_of(url)] = compute_path(url, page, title_map)
    return title_map, page_paths


def breadcrumb(page_url, page, title_map, page_paths, pagedir):
    if slug_of(page_url) == ROOT_SLUG:
        return ""
    parts = [f"[Human Interface Guidelines]({enc(rel(page_paths[ROOT_SLUG], pagedir))})"]
    for g in ancestors_after_root(page):
        gslug = slug_of(g)
        gtitle = title_for(g, title_map)
        if gslug in page_paths:
            parts.append(f"[{gtitle}]({enc(rel(page_paths[gslug], pagedir))})")
        else:
            parts.append(gtitle)
    parts.append(f"**{page.get('metadata', {}).get('title', '')}**")
    return " › ".join(parts)


def render_tree(url, children, pages, title_map, page_paths, pagedir, depth=0, seen=None):
    seen = seen or set()
    if url in seen:
        return ""
    seen.add(url)
    lines = []
    for child in children.get(url, []):
        cslug = slug_of(child)
        ctitle = title_map.get(cslug, cslug.replace("-", " ").capitalize())
        if cslug in page_paths:
            link = f"[{ctitle}]({enc(rel(page_paths[cslug], pagedir))})"
        else:
            link = ctitle
        lines.append("  " * depth + f"- {link}")
        lines.append(render_tree(child, children, pages, title_map, page_paths, pagedir, depth + 1, seen))
    return "\n".join(l for l in lines if l)


def render_page_md(page_url, page, title_map, page_paths, children, images):
    relpath = page_paths[slug_of(page_url)]
    pagedir = posixpath.dirname(relpath)
    ctx = {
        "refs": page.get("references", {}),
        "page_paths": page_paths,
        "title_map": title_map,
        "pagedir": pagedir,
        "images": images,
    }
    title = page.get("metadata", {}).get("title", slug_of(page_url))
    md = []

    if slug_of(page_url) == ROOT_SLUG and README_MODE:
        md.append("<!-- Auto-generated from Apple's Human Interface Guidelines by "
                  "hig_download.py — do not edit by hand; this file is overwritten on each run. -->")
        md.append("")

    crumb = breadcrumb(page_url, page, title_map, page_paths, pagedir)
    if crumb:
        md.append(crumb)
        md.append("")

    md.append(f"# {title}")
    md.append("")

    abstract = page.get("abstract")
    if abstract:
        a = render_inline(abstract, ctx).strip()
        if a:
            md.append(f"*{a}*")
            md.append("")

    alert = page.get("metadata", {}).get("customMetadata", {}).get("alert-text")
    if alert:
        md.append(f"> **Note**\n>\n> {esc(alert)}")
        md.append("")

    for sec in page.get("primaryContentSections", []) or []:
        if sec.get("kind") == "content":
            md.append(render_blocks(sec.get("content", []), ctx).rstrip())
            md.append("")

    # Root landing page gets the full contents tree.
    if slug_of(page_url) == ROOT_SLUG and children:
        tree = render_tree(page_url, children, {}, title_map, page_paths, pagedir)
        if tree:
            md.append("## Contents")
            md.append("")
            md.append(tree)
            md.append("")

    md.append("---")
    md.append(f"*Source: [{BASE}{page_url}]({BASE}{page_url})*")
    return "\n".join(md).rstrip() + "\n"


# ---------------------------------------------------------------------------
# Image download
# ---------------------------------------------------------------------------

def download_images(images, out_dir, workers):
    assets = os.path.join(out_dir, "_assets")
    os.makedirs(assets, exist_ok=True)
    todo = []
    for fname, url in images.items():
        dest = os.path.join(assets, fname)
        if os.path.exists(dest) and os.path.getsize(dest) > 0:
            continue
        todo.append((fname, url, dest))
    if not todo:
        print(f"  images: all {len(images)} already present", flush=True)
        return
    done = {"n": 0, "fail": 0}

    def grab(job):
        fname, url, dest = job
        try:
            data = _fetch(url, binary=True)
            with open(dest, "wb") as f:
                f.write(data)
            done["n"] += 1
        except Exception as e:  # noqa: BLE001
            done["fail"] += 1
            print(f"  ! image fail {fname}: {e}", flush=True)
        if done["n"] % 25 == 0:
            print(f"  images: {done['n']}/{len(todo)}", flush=True)

    with cf.ThreadPoolExecutor(max_workers=workers) as pool:
        list(pool.map(grab, todo))
    print(f"  images: downloaded {done['n']}, failed {done['fail']}, total refs {len(images)}", flush=True)


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    ap = argparse.ArgumentParser(description="Download Apple HIG to local Markdown.")
    ap.add_argument("--out", default="output", help="Output directory")
    ap.add_argument("--workers", type=int, default=8, help="Parallel workers")
    ap.add_argument("--images", choices=["local", "remote", "none"], default="local",
                    help="local=download files, remote=keep Apple CDN URLs, none=alt text only")
    ap.add_argument("--no-images", action="store_true", help="Alias for --images none")
    ap.add_argument("--readme", action="store_true",
                    help="Name the landing page README.md (for a GitHub repo)")
    ap.add_argument("--limit", type=int, default=0, help="Stop after N pages (test)")
    ap.add_argument("--pages", default="", help="Only these comma-separated slugs")
    args = ap.parse_args()

    global ROOT_FILENAME, IMG_MODE, README_MODE
    IMG_MODE = "none" if args.no_images else args.images
    README_MODE = args.readme
    ROOT_FILENAME = "README.md" if args.readme else "human-interface-guidelines.md"

    out_dir = os.path.abspath(args.out)
    os.makedirs(out_dir, exist_ok=True)

    t0 = time.time()
    if args.pages:
        print(f"Fetching specific pages: {args.pages}", flush=True)
        pages, children = fetch_specific(args.pages.split(","), args.workers)
    else:
        print("Crawling HIG navigation tree...", flush=True)
        pages, children = crawl(args.workers, args.limit)
    print(f"Discovered {len(pages)} pages in {time.time() - t0:.1f}s", flush=True)

    title_map, page_paths = build_maps(pages)

    print("Rendering Markdown...", flush=True)
    images = {}
    written = 0
    for url, page in pages.items():
        try:
            md = render_page_md(url, page, title_map, page_paths, children, images)
        except Exception as e:  # noqa: BLE001
            print(f"  ! render fail {url}: {e}", flush=True)
            continue
        dest = os.path.join(out_dir, page_paths[slug_of(url)])
        os.makedirs(os.path.dirname(dest) or out_dir, exist_ok=True)
        with open(dest, "w", encoding="utf-8") as f:
            f.write(md)
        written += 1
    print(f"Wrote {written} markdown files", flush=True)
    print(f"Referenced {len(images)} unique images", flush=True)

    if IMG_MODE == "local":
        print("Downloading images...", flush=True)
        download_images(images, out_dir, args.workers)
    elif IMG_MODE == "remote":
        print("Images: using remote Apple CDN URLs (nothing downloaded)", flush=True)
    else:
        print("Images: alt-text only (nothing downloaded)", flush=True)

    print(f"DONE in {time.time() - t0:.1f}s -> {out_dir}", flush=True)


if __name__ == "__main__":
    main()
