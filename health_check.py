#!/usr/bin/env python3
"""
Simple health check script for Google Scholar MCP Server
Tests if the server is accessible and responding
"""

import sys
import urllib.request
import urllib.error
import json
import socket

def get_local_ip():
    """Get the local IP address"""
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        s.connect(('8.8.8.8', 80))
        ip = s.getsockname()[0]
    except Exception:
        ip = 'localhost'
    finally:
        s.close()
    return ip

def check_health(url):
    """Check if the server is healthy"""
    try:
        with urllib.request.urlopen(url, timeout=5) as response:
            if response.status == 200:
                return True, "OK"
            else:
                return False, f"HTTP {response.status}"
    except urllib.error.URLError as e:
        return False, str(e)
    except Exception as e:
        return False, str(e)

def main():
    print("=" * 50)
    print("Google Scholar MCP Server - Health Check")
    print("=" * 50)
    print()
    
    local_ip = get_local_ip()
    
    # Test localhost
    print("Testing localhost...")
    success, message = check_health("http://localhost:3847/health")
    if success:
        print(f"✅ Localhost: {message}")
    else:
        print(f"❌ Localhost: {message}")
    
    print()
    
    # Test network IP
    print(f"Testing network IP ({local_ip})...")
    success, message = check_health(f"http://{local_ip}:3847/health")
    if success:
        print(f"✅ Network: {message}")
    else:
        print(f"❌ Network: {message}")
    
    print()
    print("=" * 50)
    print(f"Server URL: http://{local_ip}:3847")
    print("=" * 50)

if __name__ == "__main__":
    main()
