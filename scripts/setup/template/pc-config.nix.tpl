{ inputs, config, pkgs, ... }:

{
  networking.hostName = "{{PC_NAME}}";
  system.stateVersion = "{{NIXPKGS_VERSION}}";

  imports = [
    ../default.nix
    ./users/users.nix
  ];

  {{GRUB_LINE}}
}
