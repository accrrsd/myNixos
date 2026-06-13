{pkgs, lib, ...}:

{
  system.autoUpgrade.enable = true;
  system.autoUpgrade.dates = "weekly";

  nix.settings = {
    keep-outputs = true;
    keep-derivations = true;
    auto-optimise-store = true;
  };

  # disabled for test reasons
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 7d";
  };
}
