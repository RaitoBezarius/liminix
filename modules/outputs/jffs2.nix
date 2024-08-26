{
  config
, pkgs
, lib
, ...
}:
let
  inherit (pkgs) liminix;
  inherit (lib) mkIf;
  o = config.system.outputs;
in
{
  imports = [
    ./initramfs.nix
  ];

  config = mkIf (config.rootfsType == "jffs2") {
    kernel.config = {
      JFFS2_FS = "y";
      JFFS2_LZO = "y";
      JFFS2_RTIME = "y";
      JFFS2_COMPRESSION_OPTIONS = "y";
      JFFS2_ZLIB = "y";
      JFFS2_CMODE_SIZE = "y";
    };
    boot.initramfs.enable = true;
    system.outputs = {
      rootfs = liminix.builders.jffs2 {
        bootableRootDirectory = o.bootablerootdir;
        inherit (config.hardware.flash) eraseBlockSize;
      };
    };
  };
}
