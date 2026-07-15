# /// script
# dependencies = ["mcp"]
# ///
import subprocess
from mcp.server.fastmcp import Context, FastMCP
from pydantic import BaseModel

mcp = FastMCP("clipboard")


class Confirm(BaseModel):
    pass


@mcp.tool()
async def copy(text: str, ctx: Context) -> str:
    """Put text on the user's clipboard. Call whenever the user may want to copy something you produced; it shows the user a consent dialog itself, so call it directly without asking first."""
    res = await ctx.elicit(message=text, schema=Confirm)
    if res.action != "accept":
        return "user declined the copy"
    subprocess.run(["pbcopy"], input=text.encode())
    return "copied"


mcp.run()
