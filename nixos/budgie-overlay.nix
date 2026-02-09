{ pkgs-budgie, ... }:

let
  budgiePackages = [
    "budgie-desktop"
    "budgie-desktop-view"
    "budgie-backgrounds"
    "budgie-control-center"
    "budgie-screensaver"
    "budgie-session"
    "budgie-desktop-with-plugins"
  ];
in
{
  nixpkgs.overlays = [
    (final: prev:
      builtins.listToAttrs (map (name: {
        inherit name;
        value = pkgs-budgie.${name};
      }) budgiePackages)
    )
  ];
}
