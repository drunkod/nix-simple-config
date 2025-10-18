{ config, pkgs, ... }:

{
  imports = [
    ./modules/espanso.nix
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
    #windsurf
    
    # Browsers
    google-chrome
    microsoft-edge
    
    # Utilities
    usbutils
    pciutils
    scrcpy
    audio-recorder
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
