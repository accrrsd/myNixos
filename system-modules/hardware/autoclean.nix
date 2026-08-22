{pkgs, lib, ...}:

# ! CRASHES SESSION START, DO NOT USE ANY OF THAT

{
  system.autoUpgrade.enable = true;
  system.autoUpgrade.dates = "weekly";

  nix.settings = {
    keep-outputs = true;
    keep-derivations = true;
    auto-optimise-store = true;
  };

  nix.gc = {
    automatic = false;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
}