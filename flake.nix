{
  description = "Alex's NixOS Configuration";

  inputs = {
    # Main system packages
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    # Pinned nixpkgs for Valent (replace COMMIT_HASH with actual hash)
    nixpkgs-valent.url = "github:nixos/nixpkgs/9ba0962c381ef85795172bd01ee57de1a84834ee";
    
    # Home Manager for user packages
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Zen Browser
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
  };

  outputs = { self, nixpkgs, nixpkgs-valent, home-manager, zen-browser, ... }: {
    # NixOS configuration
    nixosConfigurations.hp = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { 
        inherit zen-browser;
        pkgs-valent = import nixpkgs-valent {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
      };
      modules = [
        ./nixos/configuration.nix
        
        # Integrate Home Manager
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.alex = import ./home-manager/home.nix;
        }
      ];
    };
  };
}