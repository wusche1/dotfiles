#!/usr/bin/env -S uv run --quiet --with pyyaml --script
# Reads docs/cheatsheet.yaml and writes docs/index.html.
import html
from pathlib import Path

import yaml

DOCS = Path(__file__).resolve().parent.parent / "docs"
data = yaml.safe_load((DOCS / "cheatsheet.yaml").read_text())


def kbd(keys):
    return '<span class="then">then</span>'.join(f"<kbd>{html.escape(k)}</kbd>" for k in keys)


def card(s, cls=""):
    body = ""
    if s.get("note"):
        body += f'<p class="note">{s["note"]}</p>'
    if s.get("kind") == "concept":
        body += "".join(f"<p>{p}</p>" for p in s.get("text", []))
    else:
        rows = "".join(
            f"<tr><td class=keys>{kbd(r['keys'])}</td><td>{r['desc']}</td></tr>"
            for r in s.get("rows", [])
        )
        body += f"<table>{rows}</table>"
    return f'<section class="{cls}"><h2>{s["name"]}</h2>{body}</section>'


HERO = "The mental model"
hero = "".join(card(s, "hero") for s in data["sections"] if s["name"] == HERO)
cards = "".join(card(s) for s in data["sections"] if s["name"] != HERO)
HTML = f"""<!doctype html>
<html lang=en>
<head>
<meta charset=utf-8>
<meta name=viewport content="width=device-width,initial-scale=1">
<title>{html.escape(data["title"])} — Cheat Sheet</title>
<style>
:root{{--bg:#1F1F28;--panel:#2A2A37;--fg:#DCD7BA;--muted:#C8C093;--dim:#727169;
--border:#54546D;--accent:#957FB8;--blue:#7E9CD8;--green:#98BB6C}}
*{{box-sizing:border-box}}
body{{margin:0;background:var(--bg);color:var(--fg);
font:16px/1.5 ui-sans-serif,system-ui,-apple-system,"Segoe UI",sans-serif;padding:2.5rem 1.25rem}}
.wrap{{max-width:1100px;margin:0 auto}}
.prefix-badge{{position:fixed;top:1rem;right:1rem;z-index:10;display:flex;flex-direction:column;
align-items:center;gap:.35rem;background:var(--panel);border:4px solid #E82424;border-radius:12px;
padding:.7rem 1rem;box-shadow:0 4px 18px rgba(0,0,0,.5)}}
.prefix-badge .label{{font-size:.62rem;letter-spacing:.18em;color:#E82424;font-weight:700}}
.prefix-badge kbd{{font-size:1.05rem;border-color:#E82424;color:var(--fg);padding:.25rem .6rem}}
.hero{{grid-column:1/-1;margin-top:1.75rem;border-color:var(--accent)}}
.hero h2{{color:var(--accent)}}
header{{margin-bottom:2rem;padding-right:9rem}}
h1{{margin:0;font-size:1.9rem;color:var(--fg)}}
.sub{{color:var(--muted);margin:.3rem 0 0}}
.updated{{color:var(--dim);font-size:.8rem;letter-spacing:.08em;text-transform:uppercase}}
.intro{{color:var(--muted);max-width:70ch;margin:1rem 0 0}}
.grid{{display:grid;grid-template-columns:repeat(auto-fill,minmax(320px,1fr));gap:1rem;margin-top:1.75rem}}
section{{background:var(--panel);border:1px solid var(--border);border-radius:10px;padding:1rem 1.1rem}}
h2{{margin:0 0 .6rem;font-size:1.05rem;color:var(--accent);border-bottom:1px solid var(--border);padding-bottom:.45rem}}
.note{{color:var(--dim);font-size:.85rem;margin:0 0 .7rem;font-style:italic}}
section p{{margin:.45rem 0;color:var(--fg)}}
table{{width:100%;border-collapse:collapse}}
td{{padding:.32rem 0;vertical-align:top;border-top:1px solid rgba(84,84,109,.35)}}
tr:first-child td{{border-top:none}}
td.keys{{white-space:nowrap;width:1%;padding-right:1rem}}
td:last-child{{color:var(--muted)}}
kbd{{font:.8rem ui-monospace,SFMono-Regular,Menlo,monospace;background:var(--bg);
border:1px solid var(--border);border-bottom-width:2px;border-radius:5px;padding:.1rem .4rem;color:var(--blue)}}
.then{{color:var(--dim);font-size:.72rem;margin:0 .3rem;font-style:italic}}
code{{font:.85em ui-monospace,Menlo,monospace;background:var(--bg);border:1px solid var(--border);
border-radius:4px;padding:.05rem .35rem;color:var(--green)}}
footer{{color:var(--dim);font-size:.8rem;margin-top:2rem;text-align:center}}
footer a{{color:var(--blue)}}
@page{{size:A4 portrait;margin:7mm}}
@media print{{
.prefix-badge{{display:none}}footer{{display:none}}
body{{background:#fff;color:#000;padding:0;font-size:8.5px;line-height:1.22}}
.wrap{{max-width:none}}
header{{padding-right:0;margin-bottom:.3rem}}
h1{{font-size:1.1rem}}.updated{{font-size:.55rem}}
.sub{{font-size:.7rem;margin:.1rem 0 0}}
.intro{{font-size:.7rem;margin:.2rem 0 0;max-width:none;color:#222}}
.grid{{grid-template-columns:repeat(3,1fr);gap:.35rem;margin-top:.4rem}}
.hero{{margin-top:.4rem}}.hero p{{margin:.12rem 0}}
section{{background:#fff;border-color:#bbb;break-inside:avoid;padding:.4rem .5rem;border-radius:6px}}
h2{{color:#000;font-size:.78rem;margin:0 0 .28rem;padding-bottom:.2rem}}
.note{{color:#333;font-size:.62rem;margin:0 0 .28rem}}
section p{{margin:.16rem 0;font-size:.7rem}}
td{{padding:.1rem 0;font-size:.7rem;color:#222}}td.keys{{padding-right:.5rem}}
kbd{{background:#f0f0f0;color:#000;border-color:#aaa;font-size:.62rem;padding:.02rem .25rem}}
.then{{font-size:.55rem;margin:0 .12rem}}
code{{background:#f0f0f0;color:#000;border-color:#ccc}}
}}
</style>
</head>
<body>
<div class=wrap>
<div class=prefix-badge><span class=label>PREFIX</span><kbd>Ctrl+Space</kbd></div>
<header>
<div class=updated>{html.escape(data.get("updated",""))}</div>
<h1>{html.escape(data["title"])}</h1>
<p class=sub>{html.escape(data.get("subtitle",""))}</p>
<p class=intro>{data.get("intro","")}</p>
</header>
{hero}
<div class=grid>{cards}</div>
<footer>Generated from <code>docs/cheatsheet.yaml</code> · tmux docs: <a href="https://github.com/tmux/tmux/wiki">tmux wiki</a> · Claude Code: <a href="https://code.claude.com/docs">code.claude.com/docs</a></footer>
</div>
</body>
</html>
"""
(DOCS / "index.html").write_text(HTML)
print(f"wrote {DOCS / 'index.html'} ({len(HTML)} bytes)")
