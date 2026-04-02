{
  description = "NixOS config for accrrsd-pc";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # add declarative flatpak packages
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    zapret-discord-youtube.url = "github:kartavkun/zapret-discord-youtube";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, nix-flatpak, home-manager, ... }@inputs:
  let
    pkgsUnstable = import nixpkgs-unstable {
      system = "x86_64-linux";
      config.allowUnfree = true;
    };
  in {
    nixosConfigurations.accrrsd-pc = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs pkgsUnstable; };
      system = "x86_64-linux";
      modules = [
        ./hardware-configuration.nix
        ../.
        inputs.home-manager.nixosModules.home-manager
        inputs.nix-flatpak.nixosModules.nix-flatpak
        inputs.zapret-discord-youtube.nixosModules.default
        {
          services.zapret-discord-youtube = {
            enable = true;
            config = "general(ALT)";  # Или любой конфиг из папки configs (general, general(ALT), general (SIMPLE FAKE) и т.д.)
            
            # Game Filter: "null" (отключен), "all" (TCP+UDP), "tcp" (только TCP), "udp" (только UDP)
            gameFilter = "null";  # или "all", "tcp", "udp"
            
            # Добавляем кастомные домены в list-general-user.txt
            listGeneral = [ "example.com" "test.org" "mysite.net" ];
            
            # Добавляем домены в list-exclude-user.txt (исключения)
            listExclude = [ "ubisoft.com" "origin.com" ];
            
            # Добавляем IP адреса в ipset-all.txt
            ipsetAll = [ "192.168.1.0/24" "10.0.0.1" ];
            
            # Добавляем IP адреса в ipset-exclude-user.txt (исключения)
            ipsetExclude = [ "203.0.113.0/24" ];
          };
        }
      ];
    };

    homeConfigurations = {
      accrrsd = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs { system = "x86_64-linux"; };
        # import user as command home manager, e.g home-manager switch --flake
        modules = [ 
          ../users/accrrsd
          inputs.nix-flatpak.homeManagerModules.nix-flatpak
        ];
        extraSpecialArgs = { inherit inputs pkgsUnstable; };
      };
    };
  };
}
