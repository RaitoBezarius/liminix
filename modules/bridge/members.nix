{
  liminix
, ifwait
, lib
, svc
}:
{ members, primary } :

let
  inherit (liminix.networking) interface;
  inherit (liminix.services) bundle oneshot;
  inherit (lib) mkOption types;
  addif = member : oneshot {
    name = "${primary.name}.member.${member.name}";
    up = ''
      echo "attaching $(output ${member} ifname) to $(output ${primary} ifname) bridge"
      ip link set dev $(output ${member} ifname) master $(output ${primary} ifname)
    '';
    down = ''
      echo "detaching $(output ${member} ifname) from any bridge"
      ip link set dev $(output ${member} ifname) nomaster
    '';

    dependencies = [ primary member ];
  };
in bundle {
  name = "${primary.name}.members";
  contents = map addif members;
}
