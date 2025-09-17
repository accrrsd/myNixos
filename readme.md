1. Download repo the way you like.
2. If you wanna use default-pc as start of your config - make sure it has correct boot.loader.divice (you should change it if using bios, or comment if usign uefi, you can get it from "clean" setup in /etc/nixos/configuration.nix)
3. Use script like that ./bootstrap.sh path/to/git/folder default-pc
It will create /nixosConfig folder in / (root of the disk) and you should config your pc there! No need to modify /etc/nixos
4. For rebuild use smart-rebuild.sh.