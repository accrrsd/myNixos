{ inputs, config, pkgs, ... }:

{
  networking.hostName = "{{PC_NAME}}";
  system.stateVersion = "{{NIXPKGS_VERSION}}";

  imports = [
    ../general.nix
    ./users
  ];

  {{GRUB_LINE}}
}
