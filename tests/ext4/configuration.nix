{ config, pkgs, lib, ... } :
let
  inherit (pkgs.pseudofile) dir symlink;
in {
  imports = [
    ../../modules/outputs/ext4fs.nix
  ];
  config = {
    rootfsType = "ext4";
    filesystem = dir {
      hello = {
        type = "f";
        uid = 7;
        gid = 24;
        file = "hello world";
      };
    };
  };
}
