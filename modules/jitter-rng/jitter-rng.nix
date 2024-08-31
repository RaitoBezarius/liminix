{
  liminix
, lib
, jitterentropy-rngd
}:
{ }:
let
  inherit (liminix.services) longrun;
  name = "jitterentropy-rngd";
in
longrun {
  # Does it need to be unique?
  inherit name;
  run = ''
    mkdir -p /run/jitterentropy-rngd
    ${jitterentropy-rngd}/bin/jitterentropy-rngd -v -p /run/jitterentropy-rngd/${name}.pid
  '';
}
