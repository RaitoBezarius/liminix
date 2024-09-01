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

      (in_outputs ${name}
        echo ${ifname} > ifname
        cat /sys/class/net/${ifname}/address > ether
      )
  '';
  down = "ip link delete ${ifname}";

  dependencies = optional (macAddressFromInterface != null) macAddressFromInterface;
}
