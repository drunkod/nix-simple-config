# Replace this template with the Acer machine's generated file before switching:
#   sudo nixos-generate-config
#   cp /etc/nixos/hardware-configuration.nix ./nixos/hosts/Acer/hardware-configuration.nix
{ lib, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  # This keeps flake evaluation architecture-correct without copying HP disk
  # UUIDs or device paths. The generated Acer hardware configuration must add
  # the real root filesystem, boot modules, CPU settings, and swap devices.
  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
