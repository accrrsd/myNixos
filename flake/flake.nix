{
  description = "Multi-host NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    hyprland.url = "github:hyprwm/Hyprland";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, hyprland, ... } @ inputs: let
    inherit (self) outputs;
  systems = [
    "aarch64-linux"
      "i686-linux"
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
  ];
  forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    nixosConfigurations = {
      accrrsd-pc = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs outputs; };
        modules = [
          ../configuration.nix
          ../hosts/accrrsd-pc/pc-config.nix
        ];
      };

      old-note = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs outputs; };
        modules = [
          ../configuration.nix
          ../hosts/old-note/pc-config.nix
        ];
      };
    };
  };
}

