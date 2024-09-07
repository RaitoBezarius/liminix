{
  lua
, netlink-lua
, lualinux
, iwinfo
, writeFennelScript
, runCommand
, anoia
}:
runCommand "ifwait" {} ''
  mkdir -p $out/bin
  cp -p ${writeFennelScript "ifwait" [ anoia netlink-lua ] ./ifwait.fnl} $out/bin/ifwait
  cp -p ${writeFennelScript "ifbridgeable" [ anoia lualinux iwinfo ] ./ifbridgeable.fnl} $out/bin/ifbridgeable
''
