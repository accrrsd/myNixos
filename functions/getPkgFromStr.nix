{ lib, pkgs }:
pkgString:
let
  parts = lib.tail (lib.splitString "." pkgString);
  pkg = lib.attrByPath parts null pkgs;
in
  pkg