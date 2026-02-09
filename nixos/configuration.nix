{ config, pkgs, lib, zen-browser, pkgs-valent, ... }:

let
  ruLocale = "ru_RU.UTF-8";
  ruLocaleCategories = [
    "LC_ADDRESS"
    "LC_IDENTIFICATION"
    "LC_MEASUREMENT"
    "LC_MONETARY"
    "LC_NAME"
    "LC_NUMERIC"
    "LC_PAPER"
    "LC_TELEPHONE"
    "LC_TIME"
  ];
in
{
  imports = [ ./hardware-configuration.nix ];

  # ── Nix ──────────────────────────────────────────────
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  # ── Boot ─────────────────────────────────────────────
  boot = {
    loader.grub = {
      enable = true;
      device = "/dev/sda";
      useOSProber = true;
    };
    supportedFilesystems = [ "ntfs" ];
    kernelModules = [ "mmc_block" ];
    kernel.sysctl = {
      "net.ipv4.ip_default_ttl" = 65;
      "net.ipv6.conf.all.hop_limit" = 65;
      "net.ipv6.conf.default.hop_limit" = 65;
    };
  };

  # ── Networking ───────────────────────────────────────
  networking = {
    hostName = "HP";
    networkmanager.enable = true;
  };

  # ── Localization ─────────────────────────────────────
  time.timeZone = "Asia/Yekaterinburg";
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = builtins.listToAttrs (map (cat: {
      name = cat;
      value = ruLocale;
    }) ruLocaleCategories);
  };

  # ── Desktop & Display ───────────────────────────────
  services.xserver = {
    enable = true;
    displayManager.lightdm.enable = true;
    xkb = { layout = "us"; variant = ""; };
  };
  services.desktopManager.budgie.enable = true;

  services.displayManager.autoLogin = {
    enable = true;
    user = "alex";
  };

  environment.sessionVariables.XDG_CURRENT_DESKTOP = "Budgie:GNOME";

  # ── XDG Portals ─────────────────────────────────────
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
    ];
    config.common = {
      default = [ "gnome" "gtk" ];
      "org.freedesktop.impl.portal.RemoteDesktop" = [ "gnome" ];
      "org.freedesktop.impl.portal.ScreenCast" = [ "gnome" ];
    };
  };

  # Autostart GNOME portal for Budgie (D-Bus activation workaround)
  environment.etc."xdg/autostart/xdg-desktop-portal-gnome.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Portal service (GNOME)
    Exec=${pkgs.xdg-desktop-portal-gnome}/libexec/xdg-desktop-portal-gnome
    OnlyShowIn=Budgie;GNOME;
    X-GNOME-Autostart-Phase=WindowManager
    X-GNOME-AutoRestart=true
  '';

  services.dbus.packages = [ pkgs.gnome-settings-daemon ];

  # ── Audio ────────────────────────────────────────────
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa = { enable = true; support32Bit = true; };
    pulse.enable = true;
  };

  # ── Printing ─────────────────────────────────────────
  services.printing = {
    enable = true;
    drivers = with pkgs; [ hplip hplipWithPlugin ];
  };
  services.system-config-printer.enable = true;
  programs.system-config-printer.enable = true;

  # ── Other Services ──────────────────────────────────
  services.udisks2.enable = true;
  services.fwupd.enable = true;
  services.gnome.gnome-keyring.enable = true;

  # ── Programs ─────────────────────────────────────────
  programs.kdeconnect = {
    enable = true;
    package = pkgs-valent.valent;
  };

  # ── Users ────────────────────────────────────────────
  users.users.alex = {
    isNormalUser = true;
    description = "Alex-HP";
    extraGroups = [ "networkmanager" "wheel" "adbusers" ];
  };

  # ── System Packages ─────────────────────────────────
  environment.systemPackages = [
    pkgs.git
    pkgs.android-tools
    zen-browser.packages.${pkgs.system}.default
  ];

  system.stateVersion = "25.05";
}
