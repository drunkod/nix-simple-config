{ config, pkgs, lib, ... }:

let
  # ============================================
  # PROXY CONFIGURATION
  # ============================================
  proxyPort = "7890";
  socksPort = "7891";
  noProxy = "localhost,127.0.0.1,::1,.local,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16";

  # Script to get the default route IP address
  getProxyIP = pkgs.writeShellScript "get-proxy-ip" ''
    # Method 1: Get IP from default route interface
    DEFAULT_IF=$(${pkgs.iproute2}/bin/ip route | ${pkgs.gawk}/bin/awk '/default/ {print $5; exit}')
    if [ -n "$DEFAULT_IF" ]; then
      IP=$(${pkgs.iproute2}/bin/ip -4 addr show "$DEFAULT_IF" | ${pkgs.gawk}/bin/awk '/inet / {print $2}' | ${pkgs.coreutils}/bin/cut -d/ -f1 | ${pkgs.coreutils}/bin/head -1)
      if [ -n "$IP" ]; then
        echo "$IP"
        exit 0
      fi
    fi
    
    # Method 2: Fallback - get first non-loopback IP
    IP=$(${pkgs.hostname}/bin/hostname -I | ${pkgs.gawk}/bin/awk '{print $1}')
    if [ -n "$IP" ]; then
      echo "$IP"
      exit 0
    fi
    
    # Method 3: Last resort - localhost
    echo "127.0.0.1"
  '';

  # Helper to wrap any package with dynamic proxy
  wrapWithProxy = pkg: binName: pkgs.writeShellScriptBin "${binName}-proxy" ''
    PROXY_IP=$(${getProxyIP})
    export HTTP_PROXY="http://$PROXY_IP:${proxyPort}"
    export HTTPS_PROXY="http://$PROXY_IP:${proxyPort}"
    export ALL_PROXY="socks5://$PROXY_IP:${socksPort}"
    export NO_PROXY="${noProxy}"
    export http_proxy="http://$PROXY_IP:${proxyPort}"
    export https_proxy="http://$PROXY_IP:${proxyPort}"
    export all_proxy="socks5://$PROXY_IP:${socksPort}"
    export no_proxy="${noProxy}"
    echo "🌐 Proxy: $PROXY_IP:${proxyPort}"
    exec ${pkg}/bin/${binName} "$@"
  '';

  # Script to show current proxy settings
  showProxy = pkgs.writeShellScriptBin "proxy-info" ''
    PROXY_IP=$(${getProxyIP})
    echo "════════════════════════════════════════"
    echo "  🌐 Proxy Configuration"
    echo "════════════════════════════════════════"
    echo "  Detected IP:  $PROXY_IP"
    echo "  HTTP Proxy:   http://$PROXY_IP:${proxyPort}"
    echo "  SOCKS Proxy:  socks5://$PROXY_IP:${socksPort}"
    echo "  No Proxy:     ${noProxy}"
    echo "════════════════════════════════════════"
    echo ""
    echo "Current environment:"
    echo "  HTTP_PROXY=$HTTP_PROXY"
    echo "  HTTPS_PROXY=$HTTPS_PROXY"
    echo "  ALL_PROXY=$ALL_PROXY"
  '';

  # Script to set proxy in current shell (source this)
  setProxyScript = pkgs.writeShellScriptBin "proxy-on" ''
    PROXY_IP=$(${getProxyIP})
    echo "export HTTP_PROXY=\"http://$PROXY_IP:${proxyPort}\""
    echo "export HTTPS_PROXY=\"http://$PROXY_IP:${proxyPort}\""
    echo "export ALL_PROXY=\"socks5://$PROXY_IP:${socksPort}\""
    echo "export NO_PROXY=\"${noProxy}\""
    echo "export http_proxy=\"http://$PROXY_IP:${proxyPort}\""
    echo "export https_proxy=\"http://$PROXY_IP:${proxyPort}\""
    echo "export all_proxy=\"socks5://$PROXY_IP:${socksPort}\""
    echo "export no_proxy=\"${noProxy}\""
    echo "# Run: eval \$(proxy-on)"
  '';

  unsetProxyScript = pkgs.writeShellScriptBin "proxy-off" ''
    echo "unset HTTP_PROXY HTTPS_PROXY ALL_PROXY NO_PROXY"
    echo "unset http_proxy https_proxy all_proxy no_proxy"
    echo "# Run: eval \$(proxy-off)"
  '';

in {
  # Utility scripts and wrapped applications
  home.packages = [
    showProxy
    setProxyScript
    unsetProxyScript
    
    # Wrapped applications with dynamic proxy
    (wrapWithProxy pkgs.vscode "code")
    (wrapWithProxy pkgs.windsurf "windsurf")
    (wrapWithProxy pkgs.google-chrome "google-chrome-stable")
    (wrapWithProxy pkgs.antigravity "antigravity")
  ];

  # NO vscode settings - user manages their own settings.json
  # NO git settings - user manages their own .gitconfig
  
  # Shell aliases for convenience (optional)
  programs.bash.initExtra = ''
    alias pon='eval $(proxy-on)'
    alias poff='eval $(proxy-off)'
    alias pinfo='proxy-info'
  '';
}