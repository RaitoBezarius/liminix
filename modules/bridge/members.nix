{
  liminix
, ifwait
, lib
, svc
}:
{ members, primary } :

let
  inherit (liminix.services) structuredBundle oneshot;
  inherit (lib) mapAttrs;
  addif = name: { dependencies ? [ ], member }: oneshot {
    name = "${primary.name}.member.${name}";
    up = ''
      echo "attaching $(output ${member} ifname) to $(output ${primary} ifname) bridge"
      ip link set dev $(output ${member} ifname) master $(output ${primary} ifname)
    '';
    down = ''
      echo "detaching $(output ${member} ifname) from any bridge"
      ip link set dev $(output ${member} ifname) nomaster
    '';

    dependencies = [ primary member ] ++ dependencies;
  };
in structuredBundle {
  name = "${primary.name}.members";
  contents = mapAttrs addif members;
}
