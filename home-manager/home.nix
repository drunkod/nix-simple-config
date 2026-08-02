{ ... }:

{
  imports = [
    ./common.nix
    ./modules/espanso.nix
  ];

  home = {
    username = "alex";
    homeDirectory = "/home/alex";
  };
}
