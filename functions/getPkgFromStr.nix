{ lib, pkgs }:
{ pkgString, strict ? true }:

if pkgString == null || pkgString == "" then
  if strict
  then throw "Package string is null or empty"
  else null
else
  let
    parts = lib.splitString "." pkgString;
    searchParts =
      if builtins.head parts == "pkgs"
      then lib.drop 1 parts
      else parts;

    pkg = lib.attrByPath searchParts null pkgs;
  in
    if pkg == null && strict
    then throw "Package not found: ${pkgString}"
    else pkg
