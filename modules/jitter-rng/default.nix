## CPU Jitter RNG
## ==============
##
## CPU Jitter RNG is a random number generator # providing non-physical true
## random generation # that works equally for kernel and user-land. It relies
## on the availability of a high-resolution timer.
{ lib, pkgs, ... }:
let
  inherit (lib) mkOption types;
  inherit (pkgs) liminix;
in {
  options.system.service.jitter-rng = mkOption {
    type = liminix.lib.types.serviceDefn;
  };

  config = {
    system.service.jitter-rng = pkgs.liminix.callService ./jitter-rng.nix {
    };
  };
}

