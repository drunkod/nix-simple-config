{ ... }:

{
  imports = [
    ./common-configuration.nix
    ./hardware-configuration.nix
  ];

  # ── HP-specific mounts ───────────────────────────────
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

  # ── HP-specific boot configuration ──────────────────
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

  networking.hostName = "HP";

  services.displayManager.autoLogin = {
    enable = true;
    user = "alex";
  };

  users.users.alex = {
    isNormalUser = true;
    description = "Alex-HP";
    extraGroups = [ "networkmanager" "wheel" "adbusers" ];
  };
}
