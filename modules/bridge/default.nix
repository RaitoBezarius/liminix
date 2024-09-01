## Bridge module
## =============
##
##  Allows creation of Layer 2 software "bridge" network devices.  A
##  common use case is to merge together a hardware Ethernet device
##  with one or more WLANs so that several local devices appear to be
##  on the same network.


{ lib, pkgs, config, ...}:
let
  inherit (lib) mkOption types;
  inherit (pkgs.liminix.services) oneshot;
  inherit (pkgs) liminix;
in
{
  imports = [ ../ifwait ];

  options = {
    system.service.bridge = {
      primary = mkOption { type = liminix.lib.types.serviceDefn; };
      members = mkOption { type = liminix.lib.types.serviceDefn; };
      ready = mkOption { type = liminix.lib.types.serviceDefn; };
    };
  };
  config.system.service.bridge = {
    primary = liminix.callService ./primary.nix {
      ifname = mkOption {
        type = types.str;
        description = "bridge interface name to create";
      };

      macAddressFromInterface = mkOption {
        type = types.nullOr liminix.lib.types.service;
        default = null;
        description = "reuse mac address from an existing interface service";
      };
    };
    members = config.system.callService ./members.nix {
      primary = mkOption {
        type = liminix.lib.types.interface;
        description = "primary bridge interface";
      };

      members = mkOption {
        type = types.listOf liminix.lib.types.interface;
        description = "interfaces to add to the bridge";
      };
    };

    # TODO: generalize it outside
    ready = config.system.callService ./ready.nix {
      primary = mkOption {
        type = liminix.lib.types.service;
        description = "primary bridge interface";
      };

      members = mkOption {
        type = liminix.lib.types.service;
        description = "members service";
      };
    };
  };
  config.kernel.config = {
    BRIDGE = "y";
    BRIDGE_IGMP_SNOOPING = "y";
  } // lib.optionalAttrs (config.system.service ? vlan) {
    # depends on bridge _and_ vlan. I would like there to be
    # a better way to test for the existence of vlan config:
    # maybe the module should set an `enabled` attribute?
    BRIDGE_VLAN_FILTERING = "y";
  };
}
