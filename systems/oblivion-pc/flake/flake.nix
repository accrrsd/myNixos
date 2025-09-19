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
        specialArgs = { inherit inputs; };
        system = "x86_64-linux";
        modules = [
          ./hardware-configuration.nix
          ../pc-config.nix
          inputs.home-manager.nixosModules.home-manager
        ];
      };
    };

    # allows use home-manager command without rebuild-swtich. (allow rebuild user only stuff)
    homeConfigurations = {
      accrrsd = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs { system = "x86_64-linux"; };
        # import user as command home manager, e.g home-manager --flake
        modules = [
          ../users/accrrsd/user-config.nix
        ];
        extraSpecialArgs = { inherit inputs; };
      };
    };
  };
}
