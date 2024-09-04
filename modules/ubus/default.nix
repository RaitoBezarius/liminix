## ubus
## ====
##
## ubus is a micro-bus à la D-Bus for all your needs.

{ lib, pkgs, config, ...}:
let
  inherit (lib) mkOption types;
  inherit (pkgs) liminix;
in {
  options = {
    system.service.ubus = mkOption {
      type = liminix.lib.types.serviceDefn;
    };
  };
  config = {
    system.service.ubus = liminix.callService ./service.nix {
      package = mkOption {
        type = types.package;
        default = pkgs.ubus;
      };
    };
  };
}
