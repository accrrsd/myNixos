{
  description = "NixOS config for one of the pcs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    zen-browser.url = "github:MarceColl/zen-browser-flake";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, zen-browser, ... }@inputs:
  {
    nixosConfigurations = {
      oblivion-pc = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; stateVersion = "25.05"; };
        system = "x86_64-linux";
        pkgs = import nixpkgs { system = "x86_64-linux"; };
        modules = [
          ./pc-config.nix
          inputs.home-manager.nixosModules.home-manager
        ];
      };
    };
  };
}
