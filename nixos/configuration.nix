{ config, pkgs, lib, zen-browser, pkgs-valent, ... }:

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

  # XDG Desktop Portal
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
    ];
    config = {
      common = {
        default = [ "gnome" "gtk" ];
        "org.freedesktop.impl.portal.RemoteDesktop" = [ "gnome" ];
        "org.freedesktop.impl.portal.ScreenCast" = [ "gnome" ];
      };
    };
  };

  # Autostart GNOME portal for Budgie (workaround for D-Bus activation issues)
  environment.etc."xdg/autostart/xdg-desktop-portal-gnome.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Portal service (GNOME)
    Exec=${pkgs.xdg-desktop-portal-gnome}/libexec/xdg-desktop-portal-gnome
    OnlyShowIn=Budgie;GNOME;
    X-GNOME-Autostart-Phase=WindowManager
    X-GNOME-AutoRestart=true
  '';

  # Add GNOME services needed for portals
  services.dbus.packages = with pkgs; [ 
    gnome-settings-daemon
  ];

  # Services
  services = {
    udisks2.enable = true;
    fwupd.enable = true;
    gnome.gnome-keyring.enable = true;
    
    xserver = {
      enable = true;
      desktopManager.budgie.enable = true;
      displayManager.lightdm.enable = true;
      xkb = {
        layout = "us";
        variant = "";
      };
    };
    
    displayManager.autoLogin = {
      enable = true;
      user = "alex";
    };
    
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
    package = pkgs-valent.valent; 
  };

  security.rtkit.enable = true;
  virtualisation.docker.enable = false;

  users.users.alex = {
    isNormalUser = true;
    description = "Alex-HP";
    extraGroups = [ "networkmanager" "wheel" "adbusers" ];
  };

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    git
    zen-browser.packages.${pkgs.system}.default
    android-tools
  ];

  environment.sessionVariables = {
    XDG_CURRENT_DESKTOP = "Budgie:GNOME";
  };

  system.stateVersion = "25.05";
}