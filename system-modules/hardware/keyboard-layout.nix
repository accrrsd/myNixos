{ pkgs, ... }:

{
  services.xserver.xkb = {
    layout = "us,ru";
    options = "fkeys:basic_13-24,grp:alt_shift_toggle";
  };
}