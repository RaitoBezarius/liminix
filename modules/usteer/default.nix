## usteer
## ==============
##
## usteer is a band-steering daemon for hostapd.
## this helps you optimize the roaming behavior of wireless clients (STAs) in an ESS
## consisting of multiple BSS / APs.
## you want this as soon as you are deploying Liminix on >1 APs that are close to each other.
{ lib, pkgs, ... }:
let
  inherit (lib) mkOption types;
  inherit (pkgs) liminix;
in {
  options.system.service.usteer = mkOption {
    type = liminix.lib.types.serviceDefn;
  };

  config = {
    system.service.usteer = pkgs.liminix.callService ./usteer.nix {
      ifname = mkOption {
        type = types.str;
        description = "interface name on which to connect to other usteer instances";
      };
    };
  };
}

