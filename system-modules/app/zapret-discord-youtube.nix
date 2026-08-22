### REQUIRES ZAPRET-DISCORD-YOUTUBE in FLAKES, https://github.com/kartavkun/zapret-discord-youtube
{ inputs, ... }:

{
  imports = [
    inputs.zapret-discord-youtube.nixosModules.withTestTools
  ];

  services.zapret-discord-youtube = {
    enable = true;
    configName = "general(ALT)";

    gameFilter = "null";

    listGeneral = [ "example.com" "test.org" "mysite.net" ];
    listExclude = [ "ubisoft.com" "origin.com" ];

    ipsetAll = [ "192.168.1.0/24" "10.0.0.1" ];
    ipsetExclude = [ "203.0.113.0/24" ];
  };
}

# can test stategies with sudo zapret-test-strategies