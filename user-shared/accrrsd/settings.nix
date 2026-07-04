{ config, pkgs, lib, ... }:
{
  home = {
    username = "accrrsd";
    homeDirectory = "/home/accrrsd";
  };

  # auto update changed services
  systemd.user.startServices = true;

  news.display = "silent";

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 20;
  };

  programs.git = {
    enable = true;
    settings.user.name = "Daniel";
    settings.user.email = "accrrsd@bk.ru";
  };

  xdg.enable = true;

  # for google as browser - use google-chrome-stable.desktop
  
  xdg.mimeApps.enable = false;

  home.activation.setupMimeApps = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mime_file="${config.home.homeDirectory}/.config/mimeapps.list"
    if [ ! -f "$mime_file" ]; then
      mkdir -p "$(dirname "$mime_file")"
      cat <<EOF > "$mime_file"
[Default Applications]
inode/directory=org.kde.dolphin.desktop
text/html=firefox.desktop
x-scheme-handler/http=firefox.desktop
x-scheme-handler/https=firefox.desktop
x-scheme-handler/about=firefox.desktop
x-scheme-handler/unknown=firefox.desktop
application/zip=org.kde.ark.desktop
application/x-tar=org.kde.ark.desktop
application/x-gzip=org.kde.ark.desktop
application/x-bzip2=org.kde.ark.desktop
application/x-7z-compressed=org.kde.ark.desktop
application/x-rar=org.kde.ark.desktop
application/vnd.rar=org.kde.ark.desktop
application/pdf=org.kde.okular.desktop
text/plain=org.kde.kate.desktop
image/png=org.kde.gwenview.desktop
image/jpeg=org.kde.gwenview.desktop
image/gif=org.kde.gwenview.desktop
image/webp=org.kde.gwenview.desktop
image/bmp=org.kde.gwenview.desktop
image/x-eps=org.kde.gwenview.desktop
EOF
    fi
  '';

  xdg.userDirs = {
    extraConfig = {
      XDG_GAME_DIR = "${config.home.homeDirectory}/Games";
      XDG_GAME_SAVE_DIR = "${config.home.homeDirectory}/Games/Saves";
    };
  };

  # idk, if it needed.
  xdg.configFile."menus/applications.menu".text = builtins.readFile ../../src/utils/application.menu;
}