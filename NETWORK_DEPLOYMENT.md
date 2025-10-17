# Network Deployment Summary

## What's Been Configured

Your Google Scholar MCP Server is now configured to:

### ✅ Auto-Start on Reboot
- **Docker Compose**: Configured with `restart: always` policy
- **Systemd Service**: Optional systemd service file for system-level management
- **Docker Service**: Ensures Docker daemon starts on boot

### ✅ Network Accessibility
- **Port 3847**: Exposed for HTTP/SSE access
- **Host Binding**: Server binds to `0.0.0.0` (all network interfaces)
- **Health Checks**: Built-in health monitoring endpoint at `/health`

## Quick Start Guide

### 1. Deploy the Server

Run the automated setup script:
```bash
./setup-network-server.sh
```

This script will:
- Build the Docker image
- Start the container with network access
- Configure auto-start on reboot (optional)
- Configure firewall rules (optional)
- Display your server's network address

### 2. Manual Deployment (Alternative)

```bash
# Build and start
docker compose up -d

# Enable Docker to start on boot
sudo systemctl enable docker

# (Optional) Install systemd service
sudo cp google-scholar-mcp.service /etc/systemd/system/
# Edit WorkingDirectory in the file to match your path
sudo systemctl enable google-scholar-mcp.service
sudo systemctl start google-scholar-mcp.service
```

### 3. Configure Firewall

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

### 4. Find Your Server's IP

```bash
hostname -I
# or
ip addr show
```

### 5. Test Connectivity

From the server:
```bash
./test-network.sh
```

From another computer:
```bash
curl http://YOUR_SERVER_IP:3847/health
```

## Accessing from Other Computers

### Direct HTTP Access
```
http://YOUR_SERVER_IP:3847
```

### MCP Client Configuration

**Claude Desktop** (`~/.config/claude-desktop/config.json`):
```json
{
  "mcpServers": {
    "google-scholar": {
      "url": "http://YOUR_SERVER_IP:3847/sse"
    }
  }
}
```

**Cursor** (Settings → MCP → Add new server):
```json
{
  "url": "http://YOUR_SERVER_IP:3847/sse"
}
```

## Management Commands

### Start/Stop/Restart
```bash
docker compose up -d      # Start
docker compose down       # Stop
docker compose restart    # Restart
```

### View Logs
```bash
docker compose logs -f
```

### Check Status
```bash
docker compose ps
systemctl status google-scholar-mcp.service  # If using systemd
```

### Update and Rebuild
```bash
git pull
docker compose down
docker compose build
docker compose up -d
```

## Files Created/Modified

### New Files
- `Dockerfile` - Container definition with network configuration
- `docker compose.yml` - Docker Compose orchestration with auto-restart
- `.dockerignore` - Excludes unnecessary files from build
- `google-scholar-mcp.service` - Systemd service for auto-start
- `setup-network-server.sh` - Automated deployment script
- `test-network.sh` - Network connectivity test script
- `README.Docker.md` - Comprehensive Docker documentation
- `NETWORK_DEPLOYMENT.md` - This file

### Modified Files
- `README.md` - Added Docker deployment section

## Troubleshooting

### Server Not Accessible from Network

1. **Check container is running:**
   ```bash
   docker ps | grep google-scholar-mcp
   ```

2. **Test localhost first:**
   ```bash
   curl http://localhost:3847/health
   ```

3. **Check firewall:**
   ```bash
   sudo ufw status
   # or
   sudo firewall-cmd --list-all
   ```

4. **Verify port is listening:**
   ```bash
   sudo netstat -tlnp | grep 3847
   ```

5. **Check Docker logs:**
   ```bash
   docker compose logs
   ```

### Container Doesn't Start on Reboot

1. **Ensure Docker starts on boot:**
   ```bash
   sudo systemctl enable docker
   sudo systemctl start docker
   ```

2. **Check restart policy:**
   ```bash
   docker inspect google-scholar-mcp-server | grep -i restart
   ```

3. **Use systemd service:**
   ```bash
   sudo systemctl enable google-scholar-mcp.service
   sudo systemctl status google-scholar-mcp.service
   ```

### Can't Connect from Other Computers

1. **Check your router/network configuration**
2. **Ensure computers are on the same network**
3. **Verify no network isolation (guest network, etc.)**
4. **Test with server's IP, not hostname**

## Security Considerations

### For Home Network Use
- Server binds to all interfaces (0.0.0.0)
- No authentication required
- Suitable for trusted home networks only

### For Production Use (Additional Steps Needed)
- [ ] Implement authentication
- [ ] Add HTTPS/TLS encryption
- [ ] Use reverse proxy (nginx/traefik)
- [ ] Restrict network access with firewall rules
- [ ] Set up VPN for remote access
- [ ] Regular security updates

## Next Steps

1. ✅ Deploy the server using `./setup-network-server.sh`
2. ✅ Test network access with `./test-network.sh`
3. ✅ Configure your MCP clients to use the network URL
4. ✅ Verify auto-start by rebooting your server
5. ✅ Set up monitoring/alerting (optional)

## Support

For issues or questions:
1. Check `README.Docker.md` for detailed documentation
2. Run `./test-network.sh` to diagnose connectivity issues
3. Review logs: `docker compose logs -f`
4. Check the original repository for updates

## Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [MCP Protocol Documentation](https://modelcontextprotocol.io/)
- [FastMCP Documentation](https://github.com/jlowin/fastmcp)
