{
  description = "NixOS config for accrrsd-pc";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
  {
    nixosConfigurations.accrrsd-pc = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      system = "x86_64-linux";
      modules = [
        ./hardware-configuration.nix
        ../pc-config.nix
        inputs.home-manager.nixosModules.home-manager
      ];
    };

    homeConfigurations = {
      accrrsd = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs { system = "x86_64-linux"; };
        # import user as command home manager, e.g home-manager switch --flake
        modules = [ ../users/accrrsd/user-config.nix ];
        extraSpecialArgs = { inherit inputs; };
      };
    };
  };
}
