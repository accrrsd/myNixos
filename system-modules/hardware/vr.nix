{ pkgs, config, ... }:
{
  services.monado.enable = true;
  services.monado.defaultRuntime = true;

  systemd.user.services.monado.environment = {
    STEAMVR_LH_ENABLE = "1";
    XRT_COMPOSITOR_COMPUTE = "1";
    IPC_EXIT_ON_DISCONNECT = "1";
  };

  programs.steam.package = pkgs.steam.override {
    extraProfile = ''
      # Fixes timezones on VRChat
      unset TZ
      # Allows Monado to be used
      export PRESSURE_VESSEL_IMPORT_OPENXR_1_RUNTIMES=1
    '';
  };

  # OpenXR discovery
  # home-manager.users."${config.unixname}" = {
  #   xdg.configFile."openxr/1/active_runtime.json".source =
  #     "${config.services.monado.package}/share/openxr/1/openxr_monado.json";
  #   home.file.".local/share/monado/hand-tracking-models".source = pkgs.fetchgit {
  #     url = "https://gitlab.freedesktop.org/monado/utilities/hand-tracking-models";
  #     sha256 = "sha256-x/X4HyyHdQUxn3CdMbWj5cfLvV7UyQe1D01H93UCk+M=";
  #     fetchLFS = true;
  #   };
  #   xdg.configFile."openvr/openvrpaths.vrpath".text = builtins.toJSON {
  #     config = [ "${config.home-manager.users."${config.unixname}".xdg.dataHome}/Steam/config" ];
  #     external_drivers = null;
  #     jsonid = "vrpathreg";
  #     log = [ "${config.home-manager.users."${config.unixname}".xdg.dataHome}/Steam/logs" ];
  #     runtime = [ "${pkgs.opencomposite}/lib/opencomposite" ];
  #     version = 1;
  #   };
  # };
}