{ lib }:
baseDir:
let
  extensions = [ ".jpg" ".png" ".jpeg" ".bmp" ".gif" ".webp" ];
  tryPath = ext: baseDir + ext;
  found = lib.findFirst builtins.pathExists null (map tryPath extensions);
in
  found