## Proxy Configuration Notes

Based on the codebase exploration, proxy configuration is primarily managed in `home-manager/modules/proxy.nix`.

### 1. Dynamic Gateway Detection

The configuration automatically detects your gateway IP (the proxy server) using the `get-proxy-ip` script.
It assumes the proxy is running on your network gateway (often the host machine in WSL or a VM).

How it finds the IP:

```bash
GATEWAY=$(ip route | awk '/^default/ {print $3; exit}')
```

### 2. Wrapper Scripts

Instead of setting global environment variables that might break some apps, it uses wrapper commands.
For specific applications, it creates a new executable ending in `-proxy` (for example: `claude-proxy`, `code-proxy`).

When you run a `-proxy` app:
1. It detects the current gateway IP.
2. It sets `HTTP_PROXY`, `HTTPS_PROXY`, and `ALL_PROXY` (SOCKS5) for that process.
3. It launches the application with those variables.

Currently wrapped applications:
- vscode (`code-proxy`)
- windsurf (`windsurf-proxy`)
- google-chrome (`google-chrome-stable-proxy`)
- antigravity (`antigravity-proxy`)
- claude-code (`claude-proxy`)
- codex (`codex-proxy`)

### 3. Shell Integration

It adds several aliases and utility commands to Bash:
- `pon`: alias for `eval $(proxy-on)`; enables proxy for the current shell session.
- `poff`: alias for `eval $(proxy-off)`; disables proxy for the current shell session.
- `pinfo`: shows current proxy settings and detected gateway IP.

### 4. Default Ports

Default values:
- HTTP/HTTPS: `7890`
- SOCKS5: `7891`
- No-proxy list: localhost and local network ranges are bypassed by default.

You can find the full logic in `home-manager/modules/proxy.nix`.
