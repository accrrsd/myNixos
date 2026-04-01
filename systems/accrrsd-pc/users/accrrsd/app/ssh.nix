{ config, pkgs, ... }:

{
  services.ssh-agent.enable = true;

  programs.ssh = {
    enable = true;
    enableDefaultConfig = true;
    extraConfig = ''
      Host *
        AddKeysToAgent yes 
        IdentityFile ~/.ssh/id_rsa

      Host github.com
        IdentitiesOnly yes
    '';
  };

  

  # for github simple use:    ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
  # then paste in github settings, copy by:    cat ~/.ssh/id_rsa.pub | wl-copy
  # after you can check git connection via:   ssh -T git@github.com
  # and print yes for fingerprint.

  # THX ME FROM THE PAST - 😊

  # simply use (IN DEV) /nixos-config/scripts/setup/create-ssh-github.sh
}
