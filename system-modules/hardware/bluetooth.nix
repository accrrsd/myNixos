{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.hardware.bluetooth.syncWithWindows;

  parseReg = regPath: let
    regContent = builtins.readFile regPath;

    lines = builtins.filter (x: builtins.isString x && x != "") 
      (builtins.split "[\r\n]+" (builtins.replaceStrings ["\\"] ["/"] regContent));

    keyLines = builtins.filter (line: builtins.match ".*Parameters/Keys/[0-9a-fA-F]{12}.*" line != null) lines;

    adapterLine = if (builtins.length keyLines) > 0 then builtins.head keyLines else "";
    deviceLine = if (builtins.length keyLines) > 1 then builtins.elemAt keyLines 1 else "";

    adapterMatch = builtins.match ".*Parameters/Keys/([0-9a-fA-F]{12}).*" adapterLine;
    deviceMatch = builtins.match ".*Parameters/Keys/[0-9a-fA-F]{12}/([0-9a-fA-F]{12}).*" deviceLine;

    adapterRaw = if adapterMatch == null then "" else builtins.head adapterMatch;
    deviceRaw = if deviceMatch == null then "" else builtins.head deviceMatch;

    findValue = name: let
      m = builtins.match ".*\"${name}\"=hex:([0-9a-fA-F,]+).*" regContent;
    in if m == null then "" else builtins.elemAt m 0;

    cleanHex = hexStr: lib.toUpper (builtins.replaceStrings ["," " "] ["" ""] hexStr);

    toLinuxMac = mac: let
      pairs = builtins.genList (i: builtins.substring (i * 2) 2 mac) 6;
    in builtins.concatStringsSep ":" (builtins.map (lib.toUpper) pairs);

  in if adapterRaw == "" || deviceRaw == "" then 
    builtins.throw "Bluetooth Sync: Не удалось автоматически распарсить MAC-адреса из .reg файла! Проверьте структуру путей."
  else {
    adapter = toLinuxMac adapterRaw;
    device  = toLinuxMac deviceRaw;
    ltk     = cleanHex (findValue "LTK");
    irk     = cleanHex (findValue "CentralIRK");
  };

  parsed = if cfg.regFile != null then parseReg cfg.regFile else {};

in {
  options.hardware.bluetooth.syncWithWindows = {
    regFile = mkOption {
      type = types.nullOr types.path;
      default = null;
    };
  };

  config = mkMerge [
    {
      hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
        settings = {
          General = {
            Enable = "Source,Sink,Media,Socket,HID";
            Experimental = true;
          };
        };
      };

      services.blueman.enable = true;

      environment.systemPackages = with pkgs; [
        bluez-tools
        bluetuith
      ];
    }

    (mkIf (cfg.regFile != null) {
      environment.etc."bluetooth/${parsed.adapter}/${parsed.device}/info".text = ''
        [General]
        Name=Synced BLE Device
        SupportedTechnologies=LE;
        Trusted=true

        [LongTermKey]
        Key=${parsed.ltk}
        Authenticated=0
        EncSize=16
        EDIV=0
        Rand=0

        [IdentityResolvingKey]
        Key=${parsed.irk}

        [ConnectionParameters]
        MinInterval=6
        MaxInterval=9
        Latency=0
        Timeout=210
      '';
    })
  ];
}