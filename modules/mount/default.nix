## Mount
##
## Mount filesystems


{ lib, pkgs, config, ...}:
let
  inherit (lib) mkOption types;
  inherit (pkgs) liminix;
  mkBoolOption = description : mkOption {
    type = types.bool;
    inherit description;
    default = true;
  };

in {
  options = {
    system.service.mount = mkOption {
      type = liminix.lib.types.serviceDefn;
    };
  };
  imports = [ ../mdevd.nix ];
  config.system.service.mount =
    let svc = liminix.callService ./service.nix {
          partlabel = mkOption {
            type = types.str;
            example = "my-usb-stick";
          };
          mountpoint = mkOption {
            type = types.str;
            example = "/mnt/media";
          };
          options = mkOption {
            type = types.listOf types.str;
            default = [];
            example = ["noatime" "ro" "sync"];
          };
          fstype = mkOption {
            type = types.str;
            default = "auto";
            example = "vfat";
          };
        };
    in svc // {
      build = args:
        let args' = args // {
              dependencies = (args.dependencies or []) ++ [
                config.services.mdevd
                config.services.devout
              ];
            };
        in svc.build args' ;
    };

  config.programs.busybox  = {
    applets = ["blkid" "findfs"];
    options = {
      FEATURE_BLKID_TYPE = "y";
      FEATURE_MOUNT_FLAGS = "y";
      FEATURE_MOUNT_LABEL = "y";
      FEATURE_VOLUMEID_EXT = "y";
    };
  };
}
