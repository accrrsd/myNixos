{
  description = "NixOS config for accrrsd-pc";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-old.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    antigravity-nix = {
      url = "github:jacopone/antigravity-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixcord.url = "github:FlameFlag/nixcord";
    astal.url = "github:aylur/astal";
    ags.url = "github:aylur/ags";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, nixpkgs-old, home-manager, ... }@inputs:
  let
    system = "x86_64-linux";
    overlay-old = final: prev: {
      oldpkgs = import nixpkgs-old {
        inherit system;
        config.allowUnfree = true;
      };
    };
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
        # nixos module version of HM
        inputs.home-manager.nixosModules.home-manager
        inputs.nix-flatpak.nixosModules.nix-flatpak
        {
          nixpkgs.overlays = [ overlay-unstable overlay-old ];
          nixpkgs.config.allowUnfree = true;
          # add module to home manager as nixos module
          home-manager.sharedModules = [
            inputs.nix-flatpak.homeManagerModules.nix-flatpak
          ];
        }
      ];
    };

    # standalone (hswitch) verison of HM
    homeConfigurations = {
      accrrsd = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [ overlay-unstable overlay-old ];
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