{ lib, pkgs, config, ...}:
let
  inherit (lib) mkOption types;
  inherit (pkgs.liminix.services) oneshot;
in {
  options = {
    hostname = mkOption {
      description = ''
        System hostname of the device, as returned by gethostname(2). May or
        may not correspond to any name it's reachable at on any network.
      '';
      default = "liminix";
      type = types.nonEmptyStr;
    };
  };
  config = {
    services.hostname = oneshot {
      name = "hostname-${builtins.substring 0 12 (builtins.hashString "sha256" config.hostname)}";
      up = "echo ${config.hostname} > /proc/sys/kernel/hostname";
      down = "true";
    };
  };
}
