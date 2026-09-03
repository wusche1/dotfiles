# /// script
# dependencies = ["mcp"]
# ///
import base64
from mcp.server.fastmcp import Context, FastMCP
from pydantic import BaseModel

mcp = FastMCP("clipboard")


class Confirm(BaseModel):
    pass


@mcp.tool()
async def copy(text: str, ctx: Context) -> str:
    """Put text on the user's clipboard. Call whenever the user may want to copy something you produced; it shows the user a consent dialog itself, so call it directly without asking first."""
    preview = text if len(text) <= 500 else f"{text[:500]}… ({len(text)} chars total)"
    res = await ctx.elicit(message=preview, schema=Confirm)
    if res.action != "accept":
        return "user declined the copy"
    # OSC 52: sets the clipboard of the terminal you're sitting at, even through ssh + tmux
    b64 = base64.b64encode(text.encode()).decode()
    with open("/dev/tty", "w") as tty:
        tty.write(f"\033]52;c;{b64}\a")
    return "copied"


mcp.run()
