{ ... }:

{
  imports = [
    ../../common-configuration.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "Acer";

  services.displayManager.autoLogin = {
    enable = true;
    user = "VC";
  };

  users.users.VC = {
    isNormalUser = true;
    description = "VC-Acer";
    extraGroups = [ "networkmanager" "wheel" "adbusers" ];
  };
}
