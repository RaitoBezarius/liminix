{
  config
, pkgs
, lib
, ...
}:
let
  inherit (lib) mkIf mkEnableOption mkOption types concatStringsSep;
  cfg = config.boot.loader.extlinux;
  o = config.system.outputs;
  cmdline = concatStringsSep " " config.boot.commandLine;
  wantsDtb = config.hardware.dts ? src && config.hardware.dts.src != null;
in {
  options.system.outputs.extlinux = mkOption {
    type = types.package;
    # description = "";
  };
  options.boot.loader.extlinux.enable = mkEnableOption "extlinux";

  config =  { # mkIf cfg.enable {
    system.outputs.extlinux = pkgs.runCommand "extlinux" {} ''
      mkdir $out
      cd $out
      ${if wantsDtb then "cp ${o.dtb} dtb" else "true"}
      cp ${o.initramfs} initramfs
      cp ${o.zimage}  kernel
      mkdir extlinux
      cat > extlinux/extlinux.conf << _EOF
      menu title Liminix
      timeout 100
      label Liminix
        kernel /boot/kernel
        # initrd /boot/initramfs
        append ${cmdline} root=/dev/vda1
        ${if wantsDtb then "fdt /boot/dtb" else ""}
      _EOF
    '';
  };
}
