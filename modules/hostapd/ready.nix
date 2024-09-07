{
  liminix
, ifwait
, lib
}:
{ interface } :
let
  inherit (liminix.services) oneshot;
in oneshot {
  name = "${interface.name}.wlan-oper";
  up = ''
    ${ifwait}/bin/ifbridgeable -v $(output ${interface} ifname)
  '';

  dependencies = [ interface ];
}
