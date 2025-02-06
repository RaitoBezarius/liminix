{
  liminix
, lib
, usteer
}:
{ ifname }:
let
  inherit (liminix.services) longrun;
  name = "usteerd";
in
longrun {
  # Does it need to be unique?
  inherit name;
  run = ''
    mkdir -p /run/usteerd
    ${usteer}/bin/usteerd -s -v -i ${ifname}
  '';
}
