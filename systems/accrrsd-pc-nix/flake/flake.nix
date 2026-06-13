{
  description = "NixOS config for accrrsd-pc";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    zapret-discord-youtube.url = "github:kartavkun/zapret-discord-youtube";
    antigravity-nix = {
      url = "github:jacopone/antigravity-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixcord.url = "github:FlameFlag/nixcord";
    astal.url = "github:aylur/astal";
    ags.url = "github:aylur/ags";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }@inputs:
  let
    system = "x86_64-linux";
    overlay-unstable = final: prev: {
      unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    };
  in {
    nixosConfigurations.accrrsd-pc-nix = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; }; 
      modules = [
        ./hardware-configuration.nix
        ../. 
        inputs.home-manager.nixosModules.home-manager
        inputs.nix-flatpak.nixosModules.nix-flatpak
        inputs.zapret-discord-youtube.nixosModules.default
        {
          nixpkgs.overlays = [ overlay-unstable ];
          nixpkgs.config.allowUnfree = true;
        }
      ];
    };

    homeConfigurations = {
      accrrsd = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [ overlay-unstable ];
        };
        extraSpecialArgs = { inherit inputs; };
        modules = [ 
          ../users/accrrsd
          inputs.nix-flatpak.homeManagerModules.nix-flatpak
        ];
      };
    };
  };
}