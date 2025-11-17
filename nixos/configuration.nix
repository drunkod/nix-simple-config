{ config, pkgs, lib, zen-browser, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # Nix settings
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Bootloader
  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
    useOSProber = true;
  };
  boot.supportedFilesystems = [ "ntfs" ];
  boot.kernelModules = [ "mmc_block" ];

  # Network settings
  boot.kernel.sysctl = {
    "net.ipv4.ip_default_ttl" = 65;
    "net.ipv6.conf.all.hop_limit" = 65;
    "net.ipv6.conf.default.hop_limit" = 65;
  };

  # Networking
  networking = {
    hostName = "HP";
    networkmanager.enable = true;
  };

  # Localization
  time.timeZone = "Asia/Yekaterinburg";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ru_RU.UTF-8";
    LC_IDENTIFICATION = "ru_RU.UTF-8";
    LC_MEASUREMENT = "ru_RU.UTF-8";
    LC_MONETARY = "ru_RU.UTF-8";
    LC_NAME = "ru_RU.UTF-8";
    LC_NUMERIC = "ru_RU.UTF-8";
    LC_PAPER = "ru_RU.UTF-8";
    LC_TELEPHONE = "ru_RU.UTF-8";
    LC_TIME = "ru_RU.UTF-8";
  };

  # Services
  services = {
    udisks2.enable = true;
    fwupd.enable = true;
    
    # X11 and Desktop
    xserver = {
      enable = true;
      desktopManager.budgie.enable = true;
      displayManager.lightdm.enable = true;
      xkb = {
        layout = "us";
        variant = "";
      };
    };
    
    # Auto login
    displayManager.autoLogin = {
      enable = true;
      user = "alex";
    };
    
    # Printing
    printing = {
      enable = true;
      drivers = with pkgs; [ hplip hplipWithPlugin ];
    };
    system-config-printer.enable = true;
    
    
    pulseaudio.enable = false;
    
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };

  programs.system-config-printer.enable = true;
  
  programs.kdeconnect = {
    enable = true;
    package = pkgs.valent;
  };
  # Audio
  security.rtkit.enable = true;

  # Virtualization
  virtualisation.docker.enable = false;

  programs.adb.enable = true;

  # User account
  users.users.alex = {
    isNormalUser = true;
    description = "Alex-HP";
    extraGroups = [ "networkmanager" "wheel" "adbusers" ];
  };

  # System packages
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    # os-prober
    # ntfs3g    
    git
    zen-browser.packages.${pkgs.system}.default
  ];

  system.stateVersion = "25.05";
}
