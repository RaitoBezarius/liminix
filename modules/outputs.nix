{
  config
, pkgs
, lib
, ...
}:
let
  inherit (lib) mkOption types concatStringsSep;
  inherit (pkgs) liminix callPackage writeText;
  o = config.system.outputs;
in
{
  imports = [
    ./squashfs.nix
    ./outputs/vmroot.nix
    ./outputs/extlinux.nix
  ];
  options = {
    system.outputs = {
      # the convention here is to mark an output as "internal" if
      # it's not a complete system (kernel plus userland, or installer)
      # but only part of one.
      kernel = mkOption {
        type = types.package;
        internal  = true;
        description = ''
          kernel
          ******

          Kernel vmlinux file (usually ELF)
        '';
      };
      dtb = mkOption {
        type = types.package;
        internal  = true;
        description = ''
          dtb
          ***

          Compiled device tree (FDT) for the target device
        '';
      };
      uimage = mkOption {
        type = types.package;
        internal  = true;
        description = ''
          uimage
          ******

          Combined kernel and FDT in uImage (U-Boot compatible) format
        '';
      };
      manifest = mkOption {
        type = types.package;
        internal  = true;
        description = ''
          Debugging aid. JSON rendition of config.filesystem, on
          which can run "nix-store -q --tree" on it and find
          out what's in the image, which is nice if it's unexpectedly huge
        '';
      };
      rootfsFiles = mkOption {
        type = types.package;
        internal = true;
        description = ''
          directory of files to package into root filesystem
        '';
      };
      rootfs = mkOption {
        type = types.package;
        internal = true;
        description = ''
          root filesystem (squashfs or jffs2) image
        '';
      };
    };
  };
  config = {
    system.outputs = rec {
      kernel = liminix.builders.kernel.override {
        inherit (config.kernel) config src extraPatchPhase;
      };
      dtb = liminix.builders.dtb {
        inherit (config.boot) commandLine;
        dts = config.hardware.dts.src;
        includes = config.hardware.dts.includes ++ [
          "${kernel.headers}/include"
        ];
      };
      uimage = liminix.builders.uimage {
        commandLine = concatStringsSep " " config.boot.commandLine;
        inherit (config.hardware) loadAddress entryPoint;
        inherit (config.boot) imageFormat;
        inherit kernel;
        inherit dtb;
      };
      rootfsFiles =
        let
          inherit (pkgs.pkgsBuildBuild) runCommand;
        in runCommand "mktree" { } ''
          mkdir -p $out/nix/store/ $out/secrets $out/boot
          cp ${o.systemConfiguration}/bin/activate $out/activate
          ln -s ${pkgs.s6-init-bin}/bin/init $out/init
          mkdir -p $out/nix/store
          for path in $(cat ${o.systemConfiguration}/etc/nix-store-paths) ; do
            (cd $out && cp -a $path .$path)
          done
        '';
      manifest = writeText "manifest.json" (builtins.toJSON config.filesystem.contents);
    };
  };
}
