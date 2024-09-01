{
  liminix
, ifwait
, lib
}:
{ ifname, macAddressFromInterface ? null } :
let
  inherit (liminix.services) bundle oneshot;
  inherit (lib) mkOption types optional;
in oneshot rec {
  name = "${ifname}.link";
  up = ''
    ${if macAddressFromInterface == null then
      "ip link add name ${ifname} type bridge"
      else
      "ip link add name ${ifname} address $(output ${macAddressFromInterface} ether) type bridge"}
    ${liminix.networking.ifup name ifname}
  '';
  down = "ip link set down dev ${ifname}";

  dependencies = optional (macAddressFromInterface != null) macAddressFromInterface;
}
