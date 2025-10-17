#!/bin/bash

# Test script for Google Scholar MCP Server network connectivity

echo "=========================================="
echo "Google Scholar MCP Server - Network Test"
echo "=========================================="
echo ""

# Get host IP
HOST_IP=$(hostname -I | awk '{print $1}')
echo "Server IP: $HOST_IP"
echo "Server Port: 3847"
echo ""

# Test 1: Check if container is running
echo "Test 1: Container Status"
echo "----------------------------------------"
if docker ps | grep -q google-scholar-mcp-server; then
    echo "✅ Container is running"
else
    echo "❌ Container is not running"
    echo "Start it with: docker compose up -d"
    exit 1
fi
echo ""

# Test 2: Check localhost access (TCP probe)
echo "Test 2: Localhost Access"
echo "----------------------------------------"
if (exec 3<>/dev/tcp/127.0.0.1/3847) 2>/dev/null; then
    exec 3>&- 3<&-
    echo "✅ Port open on localhost"
else
    echo "❌ Port not open on localhost"
fi
echo ""

# Test 3: Check network access (TCP probe)
echo "Test 3: Network Access (from host IP)"
echo "----------------------------------------"
if (exec 3<>/dev/tcp/$HOST_IP/3847) 2>/dev/null; then
    exec 3>&- 3<&-
    echo "✅ Port open on network interface"
else
    echo "❌ Port not open on network interface"
fi
echo ""

# Test 4: Check if port is listening
echo "Test 4: Port Listening"
echo "----------------------------------------"
if sudo netstat -tlnp 2>/dev/null | grep -q ":3847 " || sudo ss -tlnp 2>/dev/null | grep -q ":3847 "; then
    echo "✅ Port 3847 is listening"
else
    echo "⚠️  Port 3847 status unknown (requires netstat or ss)"
fi
echo ""

# Test 5: Check firewall
echo "Test 5: Firewall Status"
echo "----------------------------------------"
if command -v ufw &> /dev/null; then
    if sudo ufw status | grep -q "3847.*ALLOW"; then
        echo "✅ UFW firewall allows port 3847"
    else
        echo "⚠️  UFW may be blocking port 3847"
        echo "Run: sudo ufw allow 3847/tcp"
    fi
elif command -v firewall-cmd &> /dev/null; then
    if sudo firewall-cmd --list-ports | grep -q "3847/tcp"; then
        echo "✅ firewalld allows port 3847"
    else
        echo "⚠️  firewalld may be blocking port 3847"
        echo "Run: sudo firewall-cmd --permanent --add-port=3847/tcp && sudo firewall-cmd --reload"
    fi
else
    echo "ℹ️  No firewall detected (ufw/firewalld)"
fi
echo ""

# Test 6: Container logs
echo "Test 6: Recent Container Logs"
echo "----------------------------------------"
docker compose logs --tail=5 2>/dev/null || docker logs google-scholar-mcp-server --tail=5 2>/dev/null
echo ""

# Summary
echo "=========================================="
echo "Summary"
echo "=========================================="
echo ""
echo "Access URLs:"
echo "  - Local:   http://localhost:3847"
echo "  - Network: http://$HOST_IP:3847"
echo ""
echo "Test from another computer:"
echo "  # From another machine, a simple TCP test:"
echo "  # Linux: timeout 3 bash -lc 'exec 3<>/dev/tcp/$HOST_IP/3847 && echo ok'"
echo "  # Or try opening in a browser: http://$HOST_IP:3847/sse"
echo ""
echo "View logs:"
echo "  docker compose logs -f"
echo ""
