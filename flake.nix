{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-budgie.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-valent.url = "github:nixos/nixpkgs/9ba0962c381ef85795172bd01ee57de1a84834ee";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser.url = "github:0xc000022070/zen-browser-flake";
  };

  outputs = { self, nixpkgs, nixpkgs-budgie, nixpkgs-valent, home-manager, zen-browser, ... }:
    let
      system = "x86_64-linux";
      importPkgs = input: import input { inherit system; config.allowUnfree = true; };
    in
    {
      nixosConfigurations.hp = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit zen-browser;
          pkgs-valent = importPkgs nixpkgs-valent;
          pkgs-budgie = importPkgs nixpkgs-budgie;
        };
        modules = [
          ./nixos/configuration.nix
          ./nixos/budgie-overlay.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.alex = import ./home-manager/home.nix;
            };
          }
        ];
      };
    };
}
