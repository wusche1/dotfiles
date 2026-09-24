import json, os, subprocess

herdr = os.environ.get("HERDR_BIN_PATH", "herdr")

def run(*args):
    return subprocess.run([herdr, *args], capture_output=True, text=True).stdout

machines = [[]] + [["--machine", m["id"]] for m in json.loads(run("machine", "list", "--json")) if m["enabled"]]
n = 0
for scope in machines:
    out = run(*scope, "agent", "list")
    if not out.strip():
        continue
    for a in json.loads(out)["result"]["agents"]:
        n += 1
        run(*scope, "pane", "report-metadata", a["pane_id"], "--source", "agent-index", "--token", f"aidx={n}")
