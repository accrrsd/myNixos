{ config, pkgs, ... }:

{
  programs.ssh = {
    enable = true;
    extraConfig = ''
      Host github.com
        IdentityFile ~/.ssh/id_rsa
        IdentitiesOnly yes
    '';
  };

  # for github simple use:    ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
  # then paste in github settings, copy by:    cat ~/.ssh/id_rsa.pub | wl-copy
  # after you can check git connection via:   ssh -T git@github.com
  # and print yes for fingerprint.
}
