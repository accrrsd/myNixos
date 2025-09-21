{ config, lib, pkgs, ... }:

let
  cfg = config.user-modules.virtualSurround;

  virtualSurroundConfig =
    (import ../src/sound/sink-virtual-surround-7.1-hesuvi.nix) {
      hrtfPath = cfg.hrtfPath;
    };
in {
  options.user-modules.virtualSurround = {
    enable = lib.mkEnableOption "Enable PipeWire 7.1 → stereo HRTF virtual sink";

    hrtfPath = lib.mkOption {
      type = lib.types.path;
      default = ../src/sound/oal_dflt.wav;
      description = "Path to hrtf .wav file, used for virtual 7.1";
    };
  };

  config = lib.mkIf cfg.enable {
    xdg.configFile."pipewire/pipewire.conf.d/10-virtual-surround-sink.conf".text = virtualSurroundConfig;
  };
}