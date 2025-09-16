  # stylix = {
  #   enable = true;
  #   autoEnable = true;
  #   targets = {
  #     # trying to disable stylix wallpaper - needed for advanced wallpaper scripts
  #     hyprpaper.enable = lib.mkForce false;
  #     # fixes some apps
  #     gnome.enable = true;
  #     gtk.enable = true;
  #   };

  #   # does not work without autoenable
  #   #targets.qt.enable = true;
  #   #targets.kvantum.enable = true;
  #   #targets.xresources.enable = true;
    
  #   image = lib.mkIf fetchRes.success fetchRes.value;

  #   polarity = themeData.polarity;

  #   cursor = {
  #     name = themeData.cursor.${themeData.polarity}.name;
  #     size = themeData.cursor.${themeData.polarity}.size;
  #     package = lib.mkIf (maybeCursorPkg != null) maybeCursorPkg;
  #   };
  # };

      # did not use because of stylix cursor
    #./app/cursor/cursor.nix
    # ../../../scripts/home-specific/swww-update.nix



    # let
  # getPkgFromStr = import ../../../functions/getPkgFromStr.nix { inherit lib pkgs; };
  # themeData = builtins.fromJSON (builtins.readFile (./. + "/theme.json"));
  # maybeCursorPkg = getPkgFromStr themeData.cursor.${themeData.polarity}.package;

  # wallpaperCfg = themeData.wallpaper or {};
  # hasWallpaper = wallpaperCfg ? path && wallpaperCfg ? hash;
  
  # fetchRes = lib.optionalAttrs hasWallpaper (builtins.tryEval (
  #   builtins.fetchurl {
  #     url = "file://${wallpaperCfg.path}";
  #     sha256 = wallpaperCfg.hash;
  #   }
  # ));
# in



# =============== system


#../../modules/hardware/swap.nix


# Here we create nixos-editors group and allow it to edit nixos folder
# users.groups.nixos-editors = { };
# systemd.tmpfiles.rules = [
#   "d /etc/nixos 0775 root nixos-editors -"
# ];

# # Disable clearing permissions on reboot!

# boot.tmp.useTmpfs = false;
# # Used for read-write access with group nixos-editors
# system.activationScripts.nixosEditorsPerms.text = ''
#   chown -R root:nixos-editors /etc/nixos
#   chmod -R g+rw /etc/nixos
#   chmod g+s /etc/nixos
# '';

# Some programs need SUID wrappers, can be configured further or are
# started in user sessions.
# programs.mtr.enable = true;
# programs.gnupg.agent = {
#   enable = true;
#   enableSSHSupport = true;
# };