{ config, pkgs, inputs, pkgsUnstable, lib, ... }: {

  # uses unstable pkgs
  home.packages = (with pkgsUnstable; [matugen]) ++ (with pkgs; [swww rofi]) ++ (import ./scripts { inherit pkgs; });

  xdg.configFile."matugen/config.toml".source = config.lib.file.mkOutOfStoreSymlink ./config.toml;
  xdg.configFile."matugen/templates".source = config.lib.file.mkOutOfStoreSymlink ./templates;

  # home.configFile."<path>".source = "${config.programs.matugen.theme.files}/<template_output_path>";

  # In some cases like that
  # programs.gtk = {
  #   enable = true;
  #   gtk4.extraCss = "@import url(\"${config.programs.matugen.theme.files}/.config/gtk-4.0/gtk.css\");";
  #   gtk3.extraCss = "@import url(\"${config.programs.matugen.theme.files}/.config/gtk-3.0/gtk.css\");";
  # };
}