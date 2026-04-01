{
  description = "Default minimal NixOS config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations.general-pc = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./hardware-configuration.nix
        ../.
        inputs.home-manager.nixosModules.home-manager
      ];
    };

    homeConfigurations = {
      test = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs { system = "x86_64-linux"; };
        # import user as command home manager, e.g home-manager switch --flake
        modules = [../users/test];
        extraSpecialArgs = { inherit inputs; };
      };
    };
  };
}
