{ pkgs, ... }:

let
  selectWallpaperScript = pkgs.writeShellScriptBin "select-wallpaper" (builtins.readFile ./select-wallpaper.sh);
  
  selectWallpaper = pkgs.symlinkJoin {
    name = "select-wallpaper-with-completion";
    paths = [ selectWallpaperScript ];

    postBuild = ''
      # bash
      mkdir -p $out/share/bash-completion/completions
      cat << 'EOF' > $out/share/bash-completion/completions/select-wallpaper
      _select_wallpaper_completion() {
          local cur
          COMPREPLY=()
          cur="${"$"}{COMP_WORDS[COMP_CWORD]}"
          local schemes="tonal-spot fidelity content expressive fruit-salad rainbow neutral monochrome"
          if [[ ${"$"}{COMP_CWORD} -eq 1 ]] ; then
              COMPREPLY=( $(compgen -W "${"$"}{schemes}" -- "${"$"}{cur}") )
              return 0
          fi
      }
      complete -F _select_wallpaper_completion select-wallpaper
      EOF

      # zsh
      mkdir -p $out/share/zsh/site-functions
      cat << 'EOF' > $out/share/zsh/site-functions/_select-wallpaper
      #compdef select-wallpaper

      local -a schemes
      schemes=(
          'tonal-spot:Default Material You palette'
          'fidelity:Matches the source color closely'
          'content:Optimized for content-based colors'
          'expressive:High contrast and bold colors'
          'fruit-salad:High saturation playful mix'
          'rainbow:Vivid colors'
          'neutral:Desaturated minimalist palette'
          'monochrome:Shades of a single color'
      )

      _describe 'schemes' schemes
      EOF
    '';
  };

  startupMatugenUi = pkgs.writeShellScriptBin "startup-matugen-ui" (builtins.readFile ./startup-matugen-ui.sh);
in
[ selectWallpaper startupMatugenUi ]