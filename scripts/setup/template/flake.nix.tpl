{
  description = "NixOS config for {{PC_NAME}}";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-{{NIXPKGS_VERSION}}";
    home-manager = {
      url = "github:nix-community/home-manager/release-{{NIXPKGS_VERSION}}";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
  {
    nixosConfigurations.{{PC_NAME}} = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      system = "x86_64-linux";
      modules = [
        ./hardware-configuration.nix
        ../pc-config.nix
        inputs.home-manager.nixosModules.home-manager
      ];
    };

    homeConfigurations = {
      {{USER_NAME}} = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs { system = "x86_64-linux"; };
        # import user as command home manager, e.g home-manager switch --flake
        modules = [ ../users/{{USER_NAME}}/user-config.nix ];
        extraSpecialArgs = { inherit inputs; };
      };
    };
  };
}
