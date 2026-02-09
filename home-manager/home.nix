{ config, pkgs, ... }:

{
  imports = [
    ./modules/espanso.nix
    ./modules/proxy.nix
  ];

  # Basic configuration
  home = {
    username = "alex";
    homeDirectory = "/home/alex";
    stateVersion = "25.05";
  };

  # User packages
  home.packages = with pkgs; [
    # Development
    fabric-ai
    vscode
    windsurf
    antigravity

    # Browsers
    google-chrome
    microsoft-edge
    
    # Utilities
    usbutils
    pciutils
    scrcpy
    xarchiver
    libnotify

    sing-box
    crow-translate

  ];

  # Programs
  programs = {
    home-manager.enable = true;
  };

}
