{
  liminix
, writeText
, lib
}:
{ package } :
let
  inherit (liminix.services) longrun;
in longrun {
  # Long term: make it unique so that user can spawn multiple buses if they want.
  name = "ubus";
  run = "${package}/bin/ubusd";
}
