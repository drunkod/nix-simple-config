{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-budgie.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-valent.url = "github:nixos/nixpkgs/d6c71932130818840fc8fe9509cf50be8c64634f";
    codex-cli-nix.url = "github:sadjow/codex-cli-nix";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser.url = "github:0xc000022070/zen-browser-flake";
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-budgie, nixpkgs-valent, home-manager, zen-browser, codex-cli-nix, ... }:
    let
      system = "x86_64-linux";
      importPkgs = input: import input { inherit system; config.allowUnfree = true; };
      pkgs = importPkgs nixpkgs;
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [
          codex-cli-nix.packages.${system}.default
        ];
      };

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
              extraSpecialArgs = { inherit inputs; };
              users.alex = import ./home-manager/home.nix;
            };
          }
        ];
      };
    };
}
