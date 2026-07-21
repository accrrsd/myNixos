{ config, pkgs, lib, ... }:


# usage example (same for v1 version i think)

# 1. Stop zapret2 before check:
# sudo systemctl stop zapret2

# 2. Use blockcheck to find working desync strategy:
# sudo nix-shell -p zapret2 nftables --command blockcheck2
# Paste string after --lua-desync
# Example output line: curl_test_https_tls12 ipv4 discordapp.com : nfqws2 --payload=tls_client_hello --lua-desync=multidisorder:pos=1,sniext+1,host+1,midsld-2,midsld,midsld+2,endhost-1
# You paste: "multidisorder:pos=1,sniext+1,host+1,midsld-2,midsld,midsld+2,endhost-1"

# 3. Manually download/update blocked domain lists (antifilter):
# sudo systemctl start zapret2-fetch

# Configuration example in default.nix:
# services.zapret2 = {
#   enable = true;
#   # change desync profile
#   luaDesync = ["multidisorder:pos=1,sniext+1,host+1,midsld-2,midsld,midsld+2,endhost-1"];
#   # change domain list
#   # userHostlist = [ "youtube.com" "discord.com" ];
# };

let
  cfg = config.services.zapret2;
  zapretUser = "zapret";
  stateDir = "/var/lib/zapret2";

  userHostlistFile = pkgs.writeText "zapret-user-hostlist.txt" (lib.concatStringsSep "\n" cfg.userHostlist + "\n");
  userExcludeFile = pkgs.writeText "zapret-user-exclude.txt" (lib.concatStringsSep "\n" cfg.userExclude + "\n");

  fetchScript = pkgs.writeShellScript "zapret-fetch" ''
    set -euo pipefail
    TIMESTAMP=$(date +%Y-%m-%dT%H-%M-%S)
    TMP=$(mktemp)
    NEW=$(mktemp)
    trap 'rm -f "$TMP" "$NEW"' EXIT

    echo "[$TIMESTAMP] Начинаем обновление списков РКН..."

    URL_MAIN="${builtins.elemAt cfg.autoUpdate.urls 0}"
    URL_BACKUP="${builtins.elemAt cfg.autoUpdate.urls 1}"

    if ! ${pkgs.curl}/bin/curl -fsSL --connect-timeout 15 --retry 3 -o "$TMP" "$URL_MAIN"; then
      echo "[$TIMESTAMP] Ошибка скачивания основного списка. Пробуем резервный URL..."
      if ! ${pkgs.curl}/bin/curl -fsSL --connect-timeout 15 --retry 3 -o "$TMP" "$URL_BACKUP"; then
        echo "[$TIMESTAMP] КРИТИЧНО: Оба сервера недоступны. Оставляем старый список." >&2
        exit 0
      fi
    fi

    if [ ! -s "$TMP" ] || [ "$(${pkgs.coreutils}/bin/wc -c < "$TMP")" -lt 1024 ]; then
      echo "[$TIMESTAMP] КРИТИЧНО: Скачанный файл пуст или поврежден (размер < 1KB). Оставляем старый список." >&2
      exit 0
    fi

    ${pkgs.gnugrep}/bin/grep -vE '^#|^$|^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+|^([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}' "$TMP" | \
      ${pkgs.gnused}/bin/sed 's/[[:space:]].*//; s/^\*\.//' | \
      ${pkgs.coreutils}/bin/sort -u > "$NEW" || true

    if [ -s "$NEW" ]; then
      mv -f "$NEW" "${stateDir}/downloaded.txt"
      echo "[$TIMESTAMP] Успех: $(${pkgs.coreutils}/bin/wc -l < "${stateDir}/downloaded.txt") доменов загружено."
    else
      echo "[$TIMESTAMP] КРИТИЧНО: После фильтрации список оказался пустым. Оставляем старый список." >&2
      exit 0
    fi
  '';

  luaDesyncFlags = builtins.map (arg: "--lua-desync=${arg}") cfg.luaDesync;

  nfqwsArgs = [
    "--qnum=${toString cfg.nfqQueueNum}"
    "--filter-tcp=${toString cfg.targetPort}"
    "--hostlist=${stateDir}/downloaded.txt"
    "--hostlist=${userHostlistFile}"
    "--hostlist-exclude=${userExcludeFile}"
    "--hostlist-auto=${stateDir}/autohostlist.txt"
    "--hostlist-auto-fail-threshold=5"
    "--hostlist-auto-fail-time=120"
    "--hostlist-auto-debug=${stateDir}/auto-debug.log"
    "--user=${zapretUser}"
    "--payload=tls_client_hello"
    "--lua-init=@${cfg.package}/share/zapret2/lua/zapret-lib.lua"
    "--lua-init=@${cfg.package}/share/zapret2/lua/zapret-antidpi.lua"
  ] ++ luaDesyncFlags ++ cfg.extraArgs;

  initScript = pkgs.writeShellScript "zapret-init" ''
    set -euo pipefail
    mkdir -p ${stateDir}

    for f in downloaded.txt autohostlist.txt auto-debug.log; do
      [ -f "${stateDir}/$f" ] || touch "${stateDir}/$f"
    done

    chown -R ${zapretUser}:${zapretUser} ${stateDir}
    chmod 0750 ${stateDir}
    chmod 0640 ${stateDir}/downloaded.txt
    chmod 0660 ${stateDir}/autohostlist.txt
    chmod 0660 ${stateDir}/auto-debug.log
  '';
in
{
  options.services.zapret2 = {
    enable = lib.mkEnableOption "Zapret2 DPI bypass daemon (nfqws2)";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.zapret2;
      description = "The zapret2 package to use.";
    };

    uid = lib.mkOption {
      type = lib.types.int;
      default = 987;
      description = "Fixed UID for zapret user.";
    };

    gid = lib.mkOption {
      type = lib.types.int;
      default = 988;
      description = "Fixed GID for zapret group.";
    };

    targetPort = lib.mkOption {
      type = lib.types.port;
      default = 443;
      description = "Target port for intercepting TCP traffic.";
    };

    nfqQueueNum = lib.mkOption {
      type = lib.types.int;
      default = 2171;
      description = "NFQUEUE queue number for nfqws2 processing.";
    };

    luaDesync = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "wssize:wsize=1:scale=6"
        "multidisorder:pos=midsld"
      ];
      description = "Lua desync profile parameters passed to nfqws2 via --lua-desync.";
    };

    userHostlist = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "youtube.com"
        "googlevideo.com"
        "youtu.be"
        "ytimg.com"
        "ggpht.com"
        "instagram.com"
        "cdninstagram.com"
        "rutracker.org"
        "rutracker.cr"
        "discord.com"
        "discord.gg"
        "discordapp.com"
        "discordapp.net"
        "gateway.discord.gg"
        "cdn.discordapp.com"
        "dl.discordapp.net"
        "dis.gd"
        "discord.co"
        "discord.media"
        "status.discord.com"
        "discord-attachments-uploads-prd.tefocus.prod.dis.cool"
      ];
      description = "List of domains to apply DPI bypass for.";
    };

    userExclude = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "github.com"
        "githubusercontent.com"
        "nixos.org"
        "cache.nixos.org"
      ];
      description = "List of domains to exclude from DPI processing.";
    };

    dnsResolversV4 = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "1.1.1.1" "1.0.0.1" "9.9.9.9" "149.112.112.112" ];
      description = "IPv4 DNS resolvers whitelisted in nftables.";
    };

    dnsResolversV6 = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "2606:4700:4700::1111"
        "2606:4700:4700::1001"
        "2620:fe::fe"
        "2620:fe::9"
      ];
      description = "IPv6 DNS resolvers whitelisted in nftables.";
    };

    localIPv4 = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "127.0.0.0/8" "10.0.0.0/8" "172.16.0.0/12" "192.168.0.0/16" ];
      description = "Local IPv4 ranges to bypass.";
    };

    localIPv6 = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "::1/128" "fe80::/10" "fc00::/7" ];
      description = "Local IPv6 ranges to bypass.";
    };

    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Additional command line arguments passed to nfqws2.";
    };

    autoUpdate = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable periodic fetching of blocked hostlists from antifilter.";
      };

      interval = lib.mkOption {
        type = lib.types.str;
        default = "6h";
        description = "Systemd timer interval for hostlist updates.";
      };

      urls = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          "https://antifilter.download/list/domains.lst"
          "https://antifilter.download/list/allyouneed.lst"
        ];
        description = "URLs used for downloading blocked domain lists (primary and backup).";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # System User & Group
    users.groups.${zapretUser} = {
      gid = cfg.gid;
    };

    users.users.${zapretUser} = {
      uid = cfg.uid;
      group = zapretUser;
      isSystemUser = true;
      home = stateDir;
      createHome = false;
      shell = "${pkgs.shadow}/bin/nologin";
      description = "Zapret2 DPI bypass daemon";
    };

    # Firewall Rules via NFTables
    networking.nftables.enable = true;

    networking.nftables.tables.zapret = {
      family = "inet";
      content = ''
        chain output {
          type route hook output priority mangle; policy accept;

          # 1. Local traffic bypass
          oifname "lo" accept
          ip daddr { ${lib.concatStringsSep ", " cfg.localIPv4} } accept
          ip6 daddr { ${lib.concatStringsSep ", " cfg.localIPv6} } accept

          # 2. Loop protection: Zapret downloader traffic is exempt
          meta skuid ${toString cfg.uid} accept

          # 3. DNS Resolvers whitelist
          ip daddr { ${lib.concatStringsSep ", " cfg.dnsResolversV4} } accept
          ip6 daddr { ${lib.concatStringsSep ", " cfg.dnsResolversV6} } accept

          # 4. Block QUIC (UDP 443) -> forces fallback to TCP
          udp dport ${toString cfg.targetPort} reject

          # 5. TCP MSS clamping
          tcp flags syn tcp option maxseg size set 1300

          # 6. Intercept TCP 443 into NFQUEUE for nfqws2 processing
          tcp dport ${toString cfg.targetPort} queue num ${toString cfg.nfqQueueNum} bypass
        }
      '';
    };

    # State Directory Creation
    systemd.tmpfiles.rules = [
      "d ${stateDir} 0750 ${zapretUser} ${zapretUser} -"
      "f ${stateDir}/downloaded.txt 0640 ${zapretUser} ${zapretUser} -"
      "f ${stateDir}/autohostlist.txt 0660 ${zapretUser} ${zapretUser} -"
      "f ${stateDir}/auto-debug.log 0660 ${zapretUser} ${zapretUser} -"
    ];

    # Hostlist Fetch Service (Manual update service)
    systemd.services.zapret2-fetch = {
      description = "Fetch Zapret Blocked Hostlists";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];

      serviceConfig = {
        Type = "oneshot";
        ExecStart = fetchScript;
        User = zapretUser;
        Group = zapretUser;
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        ReadWritePaths = [ stateDir ];
        NoNewPrivileges = true;
        TimeoutStartSec = "300";
      };
    };

    systemd.timers.zapret2-fetch = lib.mkIf cfg.autoUpdate.enable {
      description = "Zapret Hostlists Update Timer";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "1min";
        OnUnitActiveSec = cfg.autoUpdate.interval;
        RandomizedDelaySec = "15min";
        Persistent = true;
      };
    };

    # Main Zapret2 Service (nfqws2)
    systemd.services.zapret2 = {
      description = "Zapret2 DPI Bypass (nfqws2)";
      after = [ "network-online.target" "nftables.service" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";

        ExecStartPre = [
          "+${initScript}"
        ];

        ExecStart = "${cfg.package}/bin/nfqws2 ${lib.concatStringsSep " " nfqwsArgs}";

        User = "root";
        Group = "root";

        Environment = [
          "ZAPRET_BASE=${cfg.package}/share/zapret2"
          "ZAPRET_RW=${stateDir}"
        ];

        CapabilityBoundingSet = [
          "CAP_NET_ADMIN"
          "CAP_NET_RAW"
          "CAP_SETPCAP"
          "CAP_SETUID"
          "CAP_SETGID"
          "CAP_DAC_OVERRIDE"
          "CAP_CHOWN"
          "CAP_FOWNER"
        ];

        NoNewPrivileges = false;
        ProtectHome = true;
        PrivateTmp = true;
        PrivateDevices = true;
        ReadWritePaths = [ stateDir ];

        Restart = "on-failure";
        RestartSec = "5s";
      };
    };
  };
}
