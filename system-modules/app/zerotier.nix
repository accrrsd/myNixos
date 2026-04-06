{ config, pkgs, ... }:

{
  services.zerotierone.enable = true;

  # as conaitner it is work, but as gui - its not. Leave here as example of declarative docker container. Maybe fix it someday.

  # virtualisation.oci-containers = {
  #   backend = "docker";
  #   containers."zeroui" = {
  #     image = "dec0dos/zero-ui:latest";
  #     ports = []; 
  #     environment = {
  #       "ZU_CONTROLLER_ENDPOINT" = "http://127.0.0.1:9993";
  #       "ZU_CONTROLLER_TOKEN" = "2tvlyd1zx2rx7lndt4uxf07t"; 
  #       "ZU_SECURE_COOKIE" = "false";
  #       "ZU_DEFAULT_USERNAME" = "admin";
  #       "ZU_DEFAULT_PASSWORD" = "1";
  #     };
  #     volumes = [
  #       "/var/lib/zeroui:/app/backend/data"
  #     ];
  #     extraOptions = [ "--network=host" ];
  #   };
  # };

  # systemd.services."docker-zeroui" = {
  #   after = [ "zerotierone.service" "network.target" ];
  #   requires = [ "zerotierone.service" ];
  #   serviceConfig = {
  #     TimeoutStartSec = 0;
  #     Restart = "always";
  #     RestartSec = "10s";
  #   };
  # };

  # networking.firewall.allowedTCPPorts = [ 4000 ];

  # systemd.tmpfiles.rules = [
  #   "d /var/lib/zeroui 0755 root root -"
  # ];
}