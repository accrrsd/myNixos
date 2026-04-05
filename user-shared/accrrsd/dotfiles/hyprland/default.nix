{ colorPreset ? "" }:
let
  baseFiles = [
    ./exec.conf
    ./env.conf
    ./general.conf
    ./rules.conf
    ./binds.conf
  ];

  colorFile =
    if colorPreset == "pywal"    then ./colors/hypr-pywal.conf
    else if colorPreset == "matugen" then ./colors/hypr-matugen.conf
    else null;

  allFiles = baseFiles ++ (if colorFile != null then [ colorFile ] else []);
in
  assert builtins.elem colorPreset [ "" "pywal" "matugen" ];
  "\n" + builtins.concatStringsSep "\n" (map builtins.readFile allFiles)