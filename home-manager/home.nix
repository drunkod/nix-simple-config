{ config, pkgs, inputs, ... }:

{
  imports = [
    ./modules/espanso.nix
    ./modules/proxy.nix
  ];

  home = {
    username = "alex";
    homeDirectory = "/home/alex";
    stateVersion = "25.05";

    packages = with pkgs; [
      # Development
      fabric-ai
      vscode
      windsurf
      antigravity

      # Browsers
      google-chrome
      #microsoft-edge

      # Utilities
      usbutils
      pciutils
      scrcpy
      xarchiver
      libnotify
      sing-box
      crow-translate
      inputs.codex-cli-nix.packages.${pkgs.system}.default
      ripgrep
      claude-code
    ];
  };

  programs.home-manager.enable = true;
}
