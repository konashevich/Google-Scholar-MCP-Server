#!/bin/bash

# Google Scholar MCP Server - Network Deployment Script
# This script sets up the MCP server to run on boot and be accessible over the network

set -e

echo "=========================================="
echo "Google Scholar MCP Server Setup"
echo "=========================================="
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    echo "Visit: https://docs.docker.com/engine/install/"
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    echo "Visit: https://docs.docker.com/compose/install/"
    exit 1
fi

# Get the current directory
CURRENT_DIR=$(pwd)
echo "📁 Working directory: $CURRENT_DIR"
echo ""

# Build the Docker image
echo "🔨 Building Docker image..."
docker compose build
echo "✅ Docker image built successfully"
echo ""

# Create logs directory
mkdir -p logs
echo "✅ Logs directory created"
echo ""

# Start the container
echo "🚀 Starting the MCP server..."
docker compose up -d
echo "✅ MCP server started"
echo ""

# Wait for the server to be ready
echo "⏳ Waiting for server to be ready..."
sleep 5

# Check if container is running
if docker compose ps | grep -q "Up"; then
    echo "✅ Container is running"
else
    echo "❌ Container failed to start. Check logs with: docker compose logs"
    exit 1
fi

# Get the host IP address
echo ""
echo "🌐 Network Information:"
echo "----------------------------------------"
HOST_IP=$(hostname -I | awk '{print $1}')
echo "Server IP: $HOST_IP"
echo "Server Port: 3847"
echo "Server URL: http://$HOST_IP:3847"
echo "SSE Endpoint: http://$HOST_IP:3847/sse"
echo ""

# Test the server
echo "🔍 Testing server..."
if curl -s http://localhost:3847/sse > /dev/null 2>&1; then
    echo "✅ Server is responding"
else
    echo "⚠️  Server health check failed. It may still be starting up."
fi
echo ""

# Setup systemd service (optional)
echo "=========================================="
echo "Auto-start on Boot Setup (Optional)"
echo "=========================================="
read -p "Do you want to enable auto-start on system boot? (y/n): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Update the service file with the current directory
    sed "s|WorkingDirectory=.*|WorkingDirectory=$CURRENT_DIR|g" google-scholar-mcp.service > /tmp/google-scholar-mcp.service
    
    echo "🔐 Installing systemd service (requires sudo)..."
    sudo cp /tmp/google-scholar-mcp.service /etc/systemd/system/
    sudo systemctl daemon-reload
    sudo systemctl enable google-scholar-mcp.service
    sudo systemctl enable docker
    
    echo "✅ Auto-start enabled"
    echo ""
    echo "Service management commands:"
    echo "  - Start:   sudo systemctl start google-scholar-mcp.service"
    echo "  - Stop:    sudo systemctl stop google-scholar-mcp.service"
    echo "  - Status:  sudo systemctl status google-scholar-mcp.service"
    echo "  - Logs:    sudo journalctl -u google-scholar-mcp.service -f"
else
    echo "⚠️  Skipping auto-start setup"
    echo "Note: The container will still restart automatically if Docker is running"
fi

echo ""
echo "=========================================="
echo "Firewall Configuration"
echo "=========================================="
echo "To access from other computers, ensure port 3847 is open:"
echo ""

if command -v ufw &> /dev/null; then
    read -p "Configure UFW firewall to allow port 3847? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo ufw allow 3847/tcp
        sudo ufw reload
        echo "✅ UFW firewall configured"
    fi
elif command -v firewall-cmd &> /dev/null; then
    read -p "Configure firewalld to allow port 3847? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo firewall-cmd --permanent --add-port=3847/tcp
        sudo firewall-cmd --reload
        echo "✅ firewalld configured"
    fi
else
    echo "⚠️  No firewall tool detected (ufw/firewalld)"
    echo "If you have a firewall, manually open port 3847/tcp"
fi

echo ""
echo "=========================================="
echo "✅ Setup Complete!"
echo "=========================================="
echo ""
echo "Access your MCP server from:"
echo "  - This computer: http://localhost:3847"
echo "  - Other computers: http://$HOST_IP:3847"
echo ""
echo "View logs:"
echo "  docker compose logs -f"
echo ""
echo "Stop server:"
echo "  docker compose down"
echo ""
echo "Restart server:"
echo "  docker compose restart"
echo ""
echo "📖 For more information, see README.Docker.md"
echo ""
