{
  config
, pkgs
, lib
, ...
}:
let
  inherit (lib) mkIf mkEnableOption mkOption; # types concatStringsSep;
in {
  options = {
    boot = {
      ramdisk = {
        enable = mkEnableOption (lib.mdDoc ''
          Configure kernel to enable reserving part of memory as
          an MTD-based RAM disk.  Needed for TFTP booting or for
          kexec-based revertable upgrade
        '');
      };
    };
  };
  config = mkIf config.boot.ramdisk.enable {
    kernel = {
      config = {
        MTD = "y";
        MTD_PHRAM = "y";
        MTD_CMDLINE_PARTS = "y";
        MTD_OF_PARTS = "y";
        PARTITION_ADVANCED = "y";
        MTD_BLKDEVS = "y";
        MTD_BLOCK = "y";
      };
    };
  };
}
