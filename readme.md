1. Download repo the way you like.
2. You can create your own pc by simply use of /nixos-config/scripts/setup/create-new-system.sh
3. Or you can boot into default-pc and use it as start point of your config - make sure it has correct boot.loader.divice (you should change it if using bios, or comment if usign uefi, you can get it from "clean" setup in /etc/nixos/configuration.nix)
4. On first rebuild use script ./bootstrap.sh (it will add group and uses simmilar script like smart-rebuild.sh)
   It will create /nixos-config folder in / (root of the disk) and you should config your pc there! No need to modify /etc/nixos (move that repo in /nixos-config)
5. For next rebuild use smart-rebuild.sh. If you use zsh, you can use commands like nrebuild, hswitch.
