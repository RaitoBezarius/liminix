{
  stdenv
, busybox
, buildPackages
, callPackage
, pseudofile
, runCommand
, writeText
} : { eraseBlockSize, bootableRootDirectory }:
let
  endian = if stdenv.isBigEndian then "--big-endian" else "--little-endian";
in runCommand "frob-jffs2" {
    depsBuildBuild = [ buildPackages.mtdutils ];
  } ''
    tree=${bootableRootDirectory}
    (cd $tree && mkfs.jffs2 --compression-mode=size ${endian} -e ${toString eraseBlockSize} --enable-compressor=lzo --pad --root . --output $out --squash --faketime)
  ''
