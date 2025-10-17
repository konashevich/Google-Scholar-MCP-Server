# Docker Deployment Guide

This guide explains how to build and run the Google Scholar MCP Server using Docker with network access and auto-start on reboot.

## Prerequisites

- Docker installed on your system
- Docker Compose (recommended)
- For systemd auto-start: systemd-based Linux distribution

## Network Configuration

This setup configures the MCP server to be accessible over your home network on port 3847 using HTTP/SSE transport.

## Building the Docker Image

### Using Docker

```bash
docker build -t google-scholar-mcp-server:latest .
```

### Using Docker Compose

```bash
docker compose build
```

## Running the Container

### Quick Start with Docker Compose (Recommended)

```bash
# Start the service (will restart automatically on reboot)
docker compose up -d

# View logs
docker compose logs -f

# Stop the service
docker compose down

# Restart the service
docker compose restart
```

The server will be accessible at `http://YOUR_HOST_IP:3847`

### Using Docker

```bash
# Run with automatic restart on reboot and network access
docker run -d \
  --name google-scholar-mcp \
  --restart always \
  -p 3847:3847 \
  -v $(pwd)/logs:/app/logs \
  google-scholar-mcp-server:latest

# View logs
docker logs -f google-scholar-mcp

# Stop the container
docker stop google-scholar-mcp
```

## Auto-Start on System Reboot

### Method 1: Using Docker Compose with Systemd (Recommended)

1. **Copy the systemd service file:**
   ```bash
   sudo cp google-scholar-mcp.service /etc/systemd/system/
   ```

2. **Edit the service file to update the WorkingDirectory:**
   ```bash
   sudo nano /etc/systemd/system/google-scholar-mcp.service
   ```
   Update the `WorkingDirectory` to your actual project path.

3. **Enable and start the service:**
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl enable google-scholar-mcp.service
   sudo systemctl start google-scholar-mcp.service
   ```

4. **Check service status:**
   ```bash
   sudo systemctl status google-scholar-mcp.service
   ```

5. **View logs:**
   ```bash
   sudo journalctl -u google-scholar-mcp.service -f
   ```

### Method 2: Docker Restart Policy (Simpler)

The `docker compose.yml` already includes `restart: always`, so just ensure Docker starts on boot:

```bash
# Enable Docker to start on boot
sudo systemctl enable docker

# Start the container
docker compose up -d
```

The container will now automatically start when your system boots.

## Accessing from Other Computers on Your Home Network

### Find Your Server's IP Address

```bash
# On Linux
ip addr show | grep inet

# Or
hostname -I
```

### Access from Other Computers

From any computer on your home network, you can access the MCP server at:
```
http://YOUR_SERVER_IP:3847
```

For example: `http://192.168.1.100:3847`

### Testing Network Access

From another computer on your network:
```bash
# Test if server is reachable
curl http://YOUR_SERVER_IP:3847/health

# Or open in browser
http://YOUR_SERVER_IP:3847
```

### Firewall Configuration

If you can't access the server from other computers, you may need to open port 3847:

**Ubuntu/Debian:**
```bash
sudo ufw allow 3847/tcp
sudo ufw reload
```

**CentOS/RHEL/Fedora:**
```bash
sudo firewall-cmd --permanent --add-port=3847/tcp
sudo firewall-cmd --reload
```

**Check if port is listening:**
```bash
sudo netstat -tlnp | grep 3847
# or
sudo ss -tlnp | grep 3847
```

## Configuration for MCP Clients Over Network

### Example for Claude Desktop (Network Mode)

Add to `~/.config/claude-desktop/config.json`:

```json
{
  "mcpServers": {
    "google-scholar": {
      "url": "http://YOUR_SERVER_IP:3847/sse"
    }
  }
}
```

### Example for Cursor (Network Mode)

Add to Cursor Settings → MCP → Add new server:

```json
{
  "url": "http://YOUR_SERVER_IP:3847/sse"
}
```

## Image Management

```bash
# List images
docker images | grep google-scholar-mcp-server

# Remove the image
docker rmi google-scholar-mcp-server:latest

# Clean up unused images and containers
docker system prune -a
```

## Troubleshooting

### Check if container is running
```bash
docker ps -a | grep google-scholar-mcp
# or with docker compose
docker compose ps
```

### View container logs
```bash
docker logs google-scholar-mcp
# or with docker compose
docker compose logs -f
```

### Check network connectivity
```bash
# From the host machine
curl http://localhost:3847/health

# From another machine on the network
curl http://YOUR_SERVER_IP:3847/health
```

### Verify port is exposed
```bash
docker port google-scholar-mcp
```

### Inspect the container
```bash
docker inspect google-scholar-mcp
```

### Test the server manually
```bash
docker exec -it google-scholar-mcp /bin/bash
```

### Check systemd service status
```bash
sudo systemctl status google-scholar-mcp.service
sudo journalctl -u google-scholar-mcp.service -n 50
```

### Container won't start after reboot
```bash
# Check if Docker service is enabled
sudo systemctl status docker

# Enable Docker to start on boot
sudo systemctl enable docker

# Check Docker Compose status
docker compose ps

# Restart the service
docker compose restart
```

### Network Access Issues

1. **Verify firewall rules:**
   ```bash
   sudo ufw status
   # or
   sudo firewall-cmd --list-all
   ```

2. **Check if port is listening:**
   ```bash
   sudo netstat -tlnp | grep 3847
   ```

3. **Test from host:**
   ```bash
   curl -v http://localhost:3847/health
   ```

4. **Check Docker network:**
   ```bash
   docker network ls
   docker network inspect bridge
   ```

## Security Notes

- The container runs as a non-root user (`mcpuser`) for security
- No unnecessary packages are installed
- Port 3847 is exposed for network access - ensure your firewall is configured appropriately
- Consider using HTTPS/TLS for production deployments
- Restrict access to trusted networks only

## Static IP Configuration (Recommended for Home Network)

For easier access across your network, consider setting a static IP for your server:

### Ubuntu/Debian (netplan)
Edit `/etc/netplan/01-netcfg.yaml`:
```yaml
network:
  version: 2
  ethernets:
    eth0:  # or your interface name
      dhcp4: no
      addresses:
        - 192.168.1.100/24  # Your desired static IP
      gateway4: 192.168.1.1  # Your router IP
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
```

Apply:
```bash
sudo netplan apply
```

## Customization

### Change Python Version

Edit the `Dockerfile` first line:
```dockerfile
FROM python:3.11-slim  # or python:3.12-slim
```

### Add Additional Dependencies

Edit `requirements.txt` or `pyproject.toml` and rebuild the image.

### Modify Resource Limits

Add to `docker compose.yml`:
```yaml
services:
  google-scholar-mcp:
    deploy:
      resources:
        limits:
          cpus: '1'
          memory: 512M
```
