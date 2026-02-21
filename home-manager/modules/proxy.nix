{ config, pkgs, lib, inputs, ... }:

let
  # ── Configuration ─────────────────────────────────
  proxyPort = "7890";
  socksPort = "7891";
  noProxy = "localhost,127.0.0.1,::1,.local,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16";

  # ── Gateway detection ─────────────────────────────
  getProxyIP = pkgs.writeShellScript "get-proxy-ip" ''
    GATEWAY=$(${pkgs.iproute2}/bin/ip route | ${pkgs.gawk}/bin/awk '/^default/ {print $3; exit}')
    echo "''${GATEWAY:-127.0.0.1}"
  '';

  # ── Proxy env block generator ─────────────────────
  # Generates export lines for both upper and lowercase proxy vars
  proxyExports = ip: lib.concatStringsSep "\n" [
    ''export HTTP_PROXY="http://${ip}:${proxyPort}"''
    ''export HTTPS_PROXY="http://${ip}:${proxyPort}"''
    ''export ALL_PROXY="socks5://${ip}:${socksPort}"''
    ''export NO_PROXY="${noProxy}"''
    ''export http_proxy="$HTTP_PROXY"''
    ''export https_proxy="$HTTPS_PROXY"''
    ''export all_proxy="$ALL_PROXY"''
    ''export no_proxy="$NO_PROXY"''
  ];

  # ── Wrapper for proxied applications ──────────────
  wrapWithProxy = { pkg, bin, wrapper ? "${bin}-proxy" }:
    pkgs.writeShellScriptBin wrapper ''
      PROXY_IP=$(${getProxyIP})
      ${proxyExports "$PROXY_IP"}
      echo "🌐 Proxy: $PROXY_IP:${proxyPort}"
      exec ${pkg}/bin/${bin} "$@"
    '';

  proxiedApps = [
    { pkg = pkgs.vscode;         bin = "code"; }
    { pkg = pkgs.windsurf;       bin = "windsurf"; }
    { pkg = pkgs.google-chrome;  bin = "google-chrome-stable"; }
    { pkg = pkgs.antigravity;    bin = "antigravity"; }
    { pkg = pkgs."claude-code";  bin = "claude"; wrapper = "claude"; }
    { pkg = inputs.codex-cli-nix.packages.${pkgs.system}.default; bin = "codex"; }
  ];

  # ── Utility scripts ──────────────────────────────
  proxyInfo = pkgs.writeShellScriptBin "proxy-info" ''
    PROXY_IP=$(${getProxyIP})
    cat <<EOF
    ════════════════════════════════════════
      🌐 Proxy Configuration
    ════════════════════════════════════════
      Gateway IP:   $PROXY_IP
      HTTP Proxy:   http://$PROXY_IP:${proxyPort}
      SOCKS Proxy:  socks5://$PROXY_IP:${socksPort}
      No Proxy:     ${noProxy}
    ════════════════════════════════════════

    Current environment:
      HTTP_PROXY=$HTTP_PROXY
      HTTPS_PROXY=$HTTPS_PROXY
      ALL_PROXY=$ALL_PROXY
    EOF
  '';

  proxyOn = pkgs.writeShellScriptBin "proxy-on" ''
    PROXY_IP=$(${getProxyIP})
    ${proxyExports "$PROXY_IP"}
    echo "# Run: eval \$(proxy-on)"
  '';

  proxyOff = pkgs.writeShellScriptBin "proxy-off" ''
    echo "unset HTTP_PROXY HTTPS_PROXY ALL_PROXY NO_PROXY"
    echo "unset http_proxy https_proxy all_proxy no_proxy"
    echo "# Run: eval \$(proxy-off)"
  '';

in
{
  home.packages = [
    proxyInfo
    proxyOn
    proxyOff
  ] ++ map wrapWithProxy proxiedApps;

  programs.bash.initExtra = ''
    alias pon='eval $(proxy-on)'
    alias poff='eval $(proxy-off)'
    alias pinfo='proxy-info'
  '';
}
