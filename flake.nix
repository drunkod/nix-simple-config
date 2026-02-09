{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    # Pinned nixpkgs for Budgie 10.9.x (X11)
    nixpkgs-budgie.url = "github:nixos/nixpkgs/nixos-25.11";
    
    nixpkgs-valent.url = "github:nixos/nixpkgs/9ba0962c381ef85795172bd01ee57de1a84834ee";
    
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
  };

  outputs = { self, nixpkgs, nixpkgs-budgie, nixpkgs-valent, home-manager, zen-browser, ... }: {
    nixosConfigurations.hp = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { 
        inherit zen-browser;
        pkgs-valent = import nixpkgs-valent {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
        pkgs-budgie = import nixpkgs-budgie {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
      };
      modules = [
        ./nixos/configuration.nix
        
        # Overlay: use Budgie packages from pinned nixpkgs
        ({ pkgs-budgie, ... }: {
          nixpkgs.overlays = [
            (final: prev: {
              budgie-desktop = pkgs-budgie.budgie-desktop;
              budgie-desktop-view = pkgs-budgie.budgie-desktop-view;
              budgie-backgrounds = pkgs-budgie.budgie-backgrounds;
              budgie-control-center = pkgs-budgie.budgie-control-center;
              budgie-screensaver = pkgs-budgie.budgie-screensaver;
              budgie-session = pkgs-budgie.budgie-session;
              budgie-desktop-with-plugins = pkgs-budgie.budgie-desktop-with-plugins;
              # wdisplays = pkgs-budgie.wdisplays or prev.wdisplays;
            })
          ];
        })

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