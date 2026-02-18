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

  # ── Extra Mounts ────────────────────────────────────
  fileSystems."/mnt/sda2" = {
    device = "/dev/disk/by-uuid/8FD5-9B47";
    fsType = "vfat";
    options = [
      "uid=1000"
      "gid=100"
      "utf8=1"
      "shortname=mixed"
      "fmask=0022"
      "dmask=0022"
      "x-mount.mkdir"
      "nofail"
      "x-gvfs-show"
    ];
  };

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
    supportedFilesystems = [ "ntfs" "vfat" "exfat" ];
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
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
    ];
    config.common = {
      default = [ "gtk" ];
    };
    # Budgie sessions often expose XDG_CURRENT_DESKTOP=Budgie:GNOME.
    # Keep GTK default, route only RemoteDesktop/ScreenCast to GNOME backend.
    config.budgie = {
      default = [ "gtk" ];
      "org.freedesktop.impl.portal.RemoteDesktop" = [ "gnome" ];
      "org.freedesktop.impl.portal.ScreenCast" = [ "gnome" ];
    };
    config.gnome = {
      default = [ "gtk" ];
      "org.freedesktop.impl.portal.RemoteDesktop" = [ "gnome" ];
      "org.freedesktop.impl.portal.ScreenCast" = [ "gnome" ];
    };
  };

  # Keep graphical-session.target active in Budgie sessions so DBus can start
  # xdg-desktop-portal-gnome.service without dependency timeouts.
  systemd.user.targets.graphical-session.wantedBy = [ "default.target" ];

  # Disable broken Budgie autostart entry with missing executable.
  environment.etc."xdg/autostart/org.buddiesofbudgie.SettingsDaemon.DiskUtilityNotify.desktop".text = lib.mkForce ''
    [Desktop Entry]
    Type=Application
    Name=Disable broken Budgie DiskUtilityNotify autostart
    Hidden=true
  '';

  # ── Audio ────────────────────────────────────────────
  services.pulseaudio.enable = false;
  security.polkit = {
    enable = true;
    extraConfig = ''
      polkit.addRule(function(action, subject) {
        var udisksActions = [
          "org.freedesktop.udisks2.filesystem-mount",
          "org.freedesktop.udisks2.filesystem-mount-system",
          "org.freedesktop.udisks2.filesystem-mount-other-seat",
          "org.freedesktop.udisks2.filesystem-unmount-others",
          "org.freedesktop.udisks2.encrypted-unlock",
          "org.freedesktop.udisks2.eject-media",
          "org.freedesktop.udisks2.power-off-drive"
        ];

        if (udisksActions.indexOf(action.id) >= 0 && subject.isInGroup("wheel")) {
          return polkit.Result.YES;
        }
      });
    '';
  };
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
