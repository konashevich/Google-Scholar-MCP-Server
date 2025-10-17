# ASGI entrypoint for serving FastMCP over SSE
# Exposes an ASGI app compatible with uvicorn: asgi:app

from google_scholar_server import mcp

# FastMCP exposes an ASGI-compatible SSE application
app = mcp.sse_app
