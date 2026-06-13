{pkgs, lib, ...}:

{
  system.autoUpgrade.enable = true;
  system.autoUpgrade.dates = "weekly";

  nix.settings = {
    keep-outputs = true;
    keep-derivations = true;
    auto-optimise-store = true;
  };

  # disabled because gc brake session with start up!
  nix.gc = {
    automatic = false;
    dates = "daily";
    options = "--delete-older-than 7d";
  };
}
