# Use Python 3.10 slim image as base
FROM python:3.10-slim

# Set working directory
WORKDIR /app

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Install system dependencies if needed
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    gcc \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy dependency files
COPY requirements.txt pyproject.toml ./

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt \
    && pip install --no-cache-dir "mcp[cli]>=1.4.1"

# Copy application files
COPY google_scholar_server.py google_scholar_web_search.py asgi.py ./

# Create a non-root user for security
RUN useradd -m -u 1000 mcpuser && \
    chown -R mcpuser:mcpuser /app

# Switch to non-root user
USER mcpuser

# Expose the port for network access (FastMCP SSE server)
EXPOSE 3847

# Health check - verify the TCP port is accepting connections (works with SSE)
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD python -c "import socket,sys; s=socket.socket(); s.settimeout(3); \
try:\n s.connect(('127.0.0.1',3847)); s.close(); sys.exit(0)\nexcept Exception:\n sys.exit(1)" || exit 1

# Run the MCP server (SSE/ASGI) on port 3847
CMD ["uvicorn", "asgi:app", "--host", "0.0.0.0", "--port", "3847", "--no-access-log"]
