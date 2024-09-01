{
  liminix
, ifwait
, lib
}:
{ primary, members } :
let
  inherit (liminix.services) oneshot;
in oneshot {
  name = "${primary.name}.oper";
  up = ''
    ip link set up dev $(output ${primary} ifname)
    ${ifwait}/bin/ifwait -v $(output ${primary} ifname) running
  '';
  down = "ip link set down dev $(output ${primary} ifname)";

  dependencies = [ members ];
}
