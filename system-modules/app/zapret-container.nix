/*
  Zapret OCI Container Module (Ubuntu / Sergeydigl3/zapret-discord-youtube-linux)

  CLI COMMANDS (Run from host NixOS terminal):
  -------------------------------------------
  1. Open interactive bash session inside Ubuntu container:
     sudo zapret-manager

  2. Auto-tune YouTube & Discord strategies:
     sudo zapret-auto-tune

  3. General Auto-tune:
     sudo zapret-auto-tune-general

  4. Service Management & TUI menu:
     sudo zapret-service
     sudo zapret-service status
*/

{ config, pkgs, lib, inputs, ... }:

let
  cfg = config.services.zapret-container;
  stateDir = "/var/lib/zapret-container";

  initScript = pkgs.writeShellScript "zapret-container-init" ''
    set -euo pipefail
    mkdir -p ${stateDir}/repo
    ${pkgs.rsync}/bin/rsync -a \
      --exclude="zapret-latest" \
      --exclude="nfqws" \
      --exclude="conf.env" \
      --exclude="conf.env.backup" \
      ${inputs.zapret-src}/ ${stateDir}/repo/
    chmod -R 0777 ${stateDir}/repo
  '';

  zapretManagerBin = pkgs.writeShellApplication {
    name = "zapret-manager";
    runtimeInputs = [ pkgs.docker ];
    text = ''
      if [ "$EUID" -ne 0 ]; then
        echo "Error: Root privileges required. Run with sudo."
        exit 1
      fi
      echo "=== Entering Zapret Ubuntu Container ==="
      echo "Working directory: /app"
      echo "Run ./service.sh or ./auto_tune_youtube.sh directly inside Ubuntu."
      echo "Type 'exit' to return to host NixOS terminal."
      echo "========================================"
      exec docker exec -it zapret-container /bin/bash -c "cd /app && exec /bin/bash"
    '';
  };

  zapretAutoTuneBin = pkgs.writeShellApplication {
    name = "zapret-auto-tune";
    runtimeInputs = [ pkgs.docker ];
    text = ''
      if [ "$EUID" -ne 0 ]; then
        echo "Error: Root privileges required. Run with sudo."
        exit 1
      fi
      exec docker exec -it zapret-container /bin/bash -c "cd /app && ./auto_tune_youtube.sh"
    '';
  };

  zapretAutoTuneGenBin = pkgs.writeShellApplication {
    name = "zapret-auto-tune-general";
    runtimeInputs = [ pkgs.docker ];
    text = ''
      if [ "$EUID" -ne 0 ]; then
        echo "Error: Root privileges required. Run with sudo."
        exit 1
      fi
      exec docker exec -it zapret-container /bin/bash -c "cd /app && ./auto_tune.sh"
    '';
  };

  zapretServiceBin = pkgs.writeShellApplication {
    name = "zapret-service";
    runtimeInputs = [ pkgs.docker ];
    text = ''
      if [ "$EUID" -ne 0 ]; then
        echo "Error: Root privileges required. Run with sudo."
        exit 1
      fi
      exec docker exec -it zapret-container /bin/bash -c "cd /app && ./service.sh $*"
    '';
  };
in
{
  options.services.zapret-container = {
    enable = lib.mkEnableOption "Zapret OCI Container Service (Ubuntu / Sergeydigl3)";
  };

  config = lib.mkIf cfg.enable {
    # Ensure Docker is enabled for OCI containers
    virtualisation.docker.enable = true;

    # Expose host CLI helper tools
    environment.systemPackages = [
      zapretManagerBin
      zapretAutoTuneBin
      zapretAutoTuneGenBin
      zapretServiceBin
    ];

    # Pre-start init service to sync repo files
    systemd.services.zapret-container-init = {
      description = "Zapret Container Repo Synchronizer";
      wantedBy = [ "multi-user.target" ];
      before = [ "docker-zapret-container.service" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${initScript}";
        RemainAfterExit = true;
      };
    };

    # Declarative OCI Container definition
    virtualisation.oci-containers = {
      backend = "docker";

      containers."zapret-container" = {
        image = "ubuntu:latest";
        autoStart = true;

        extraOptions = [
          "--network=host"
          "--privileged"
        ];

        volumes = [
          "${stateDir}/repo:/app"
        ];

        entrypoint = "/bin/bash";
        cmd = [
          "-c"
          ''
            export DEBIAN_FRONTEND=noninteractive
            apt-get update && apt-get install -y git curl nftables iptables ipset gawk sed grep bc pciutils procps iproute2 ca-certificates

            cd /app
            if [ ! -d "/app/zapret-latest" ] || [ ! -f "/app/nfqws" ]; then
              echo "--- Initializing Zapret binaries inside Ubuntu container ---"
              bash ./service.sh download-deps --default || true
            fi

            echo "--- Starting Zapret Service in Ubuntu container ---"
            bash ./service.sh run || true

            # Keep container PID 1 alive indefinitely so docker exec never gets disconnected
            exec tail -f /dev/null
          ''
        ];
      };
    };
  };
}
