#!/usr/bin/env python3
"""Figure capture hotkey script.

Captures a screen region and saves it as a named figure in the current project's
bib/{citation_key}/figures/ directory.

1. Reads Zotero's window title to detect which paper is open
2. Matches title to a citation key via .metadata.txt files
3. Runs macOS screencapture for region selection
4. Prompts for a figure name
5. Saves to bib/{key}/figures/{name}.png
"""

import subprocess
import sys
import tempfile
from pathlib import Path


HOME = Path("/Users/julianschulz")
CONFIG_DIR = HOME / ".config" / "figure-capture"
PROJECT_FILE = CONFIG_DIR / "current_project"
LOG_FILE = CONFIG_DIR / "last_error.log"


def log(msg: str):
    LOG_FILE.write_text(msg)


def osascript(script: str) -> str:
    result = subprocess.run(["osascript", "-e", script], capture_output=True, text=True)
    return result.stdout.strip()


def notify(title: str, message: str):
    osascript(f'display notification "{message}" with title "{title}"')


def get_zotero_title() -> "str | None":
    raw = osascript('tell application "Zotero" to get name of front window')
    if not raw:
        return None
    return raw.removesuffix(" - Zotero").strip()


def match_citation_key(window_title: str, bib_dir: Path) -> "str | None":
    best_match = None
    best_score = 0
    for metadata_file in bib_dir.glob("*/.metadata.txt"):
        meta = {}
        for line in metadata_file.read_text().splitlines():
            if ": " in line:
                k, v = line.split(": ", 1)
                meta[k.strip()] = v.strip()
        title = meta.get("Title", "")
        if not title:
            continue
        if title.lower() in window_title.lower():
            score = len(title)
            if score > best_score:
                best_score = score
                best_match = metadata_file.parent.name
    return best_match


def capture_region() -> "Path | None":
    tmp = Path(tempfile.mktemp(suffix=".png"))
    result = subprocess.run(["screencapture", "-i", "-x", str(tmp)])
    if result.returncode != 0 or not tmp.exists() or tmp.stat().st_size == 0:
        tmp.unlink(missing_ok=True)
        return None
    return tmp


def prompt_name(citation_key: str) -> "str | None":
    script = (
        f'display dialog "Figure name for {citation_key}:" '
        f'default answer "" with title "Figure Capture"'
    )
    raw = osascript(script)
    if not raw or "text returned:" not in raw:
        return None
    name = raw.split("text returned:")[-1].strip()
    return name if name else None


def fail(msg: str):
    log(msg)
    notify("Figure Capture", msg)
    sys.exit(1)


def main():
    if not PROJECT_FILE.exists():
        fail("No project configured. Run the sync daemon first.")

    project_root = Path(PROJECT_FILE.read_text().strip())
    bib_dir = project_root / "bib"
    if not bib_dir.exists():
        fail(f"bib/ not found in {project_root}")

    window_title = get_zotero_title()
    if not window_title:
        fail("Could not read Zotero window title. Is a paper open?")

    citation_key = match_citation_key(window_title, bib_dir)
    if not citation_key:
        fail(f"No matching paper found for: {window_title}")

    screenshot = capture_region()
    if not screenshot:
        sys.exit(0)  # user cancelled, not an error

    name = prompt_name(citation_key)
    if not name:
        screenshot.unlink(missing_ok=True)
        sys.exit(0)

    name = name.replace(" ", "_").replace("/", "_")
    figures_dir = bib_dir / citation_key / "figures"
    figures_dir.mkdir(exist_ok=True)
    dest = figures_dir / f"{name}.png"

    screenshot.rename(dest)
    notify("Figure Capture", f"Saved {citation_key}/{name}")


if __name__ == "__main__":
    main()
