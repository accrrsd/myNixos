{ inputs, config, pkgs, ... }:

{
  networking.hostName = "{{PC_NAME}}";

  imports = [
    ../default.nix
    ./users/users.nix
  ];

  {{GRUB_LINE}}

  system.stateVersion = "{{NIXPKGS_VERSION}}";
}
