# GL.INet GL-MT300A

{
  system = {
    crossSystem = {
      config = "mipsel-unknown-linux-musl";
      gcc = {
        abi = "32";
        arch = "mips32";          # maybe mips_24kc-
      };
    };
  };

  module = { pkgs, ...}:
    let
      openwrt = pkgs.fetchFromGitHub {
        name = "openwrt-source";
        repo = "openwrt";
        owner = "openwrt";
        rev = "a5265497a4f6da158e95d6a450cb2cb6dc085cab";
        hash = "sha256-YYi4gkpLjbOK7bM2MGQjAyEBuXJ9JNXoz/JEmYf8xE8=";
      };
    in {
      device = {
        defaultOutput = "tftproot";
        loadAddress = "0x80000000";
        entryPoint  = "0x80000000";
      };

      kernel = {
        src = pkgs.fetchurl {
          name = "linux.tar.gz";
          url = "https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.15.71.tar.gz";
          hash = "sha256-yhO2cXIeIgUxkSZf/4aAsF11uxyh+UUZu6D1h92vCD8=";
        };
        extraPatchPhase = ''
          cp -av ${openwrt}/target/linux/generic/files/* .
          chmod -R u+w .
          cp -av ${openwrt}/target/linux/ramips/files/* .
          chmod -R u+w .
          patches() {
            for i in $* ; do patch --batch --forward -p1 < $i ;done
          }
          patches ${openwrt}/target/linux/generic/backport-5.15/*.patch
          patches ${openwrt}/target/linux/generic/pending-5.15/*.patch
          patches ${openwrt}/target/linux/generic/hack-5.15/*.patch
          patches ${openwrt}/target/linux/ramips/patches-5.15/*.patch
        '';
        dts = {
          src = "${openwrt}/target/linux/ramips/dts/mt7620a_glinet_gl-mt300a.dts";
          includes = [
            "${openwrt}/target/linux/ramips/dts"
          ];
        };
        config = {
          MIPS_ELF_APPENDED_DTB = "y";
          OF = "y";
          USE_OF = "y";

          RALINK = "y";
          SOC_MT7620 = "y";

          SERIAL_8250_CONSOLE = "y";
          SERIAL_8250 = "y";
          SERIAL_CORE_CONSOLE = "y";
          SERIAL_OF_PLATFORM = "y";

          CONSOLE_LOGLEVEL_DEFAULT = "8";
          CONSOLE_LOGLEVEL_QUIET = "4";

          # "empty" initramfs source should create an initial
          # filesystem that has a /dev/console node and not much
          # else.  Note that pid 1 is started *before* the root
          # filesystem is mounted and it expects /dev/console to
          # be present already
          BLK_DEV_INITRD = "n";

          NET = "y";
          NETDEVICES = "y";
          ETHERNET = "y";
          # NET_VENDOR_ATHEROS = "y";
          # AG71XX = "y";             # ethernet (qca,qca9530-eth)
          # MFD_SYSCON = "y";         # ethernet (compatible "syscon")
          # AR8216_PHY = "y";         # eth1 is behind a switch

          MTD = "y";
          MTD_CMDLINE_PARTS = "y";
          MTD_BLOCK = "y";         # fix undefined ref to register_mtd_blktrans_devs

          CPU_LITTLE_ENDIAN= "y";

          # this is all copied from nixwrt ath79 config. Clearly not all
          # of it is device config, some of it is wifi config or
          # installation method config or ...

          "CMDLINE_PARTITION" = "y";
          "EARLY_PRINTK" = "y";
          "FW_LOADER" = "y";
          # we don't have a user helper, so we get multiple 60s pauses
          # at boot time unless we disable trying to call it
          "FW_LOADER_USER_HELPER" = "n";

          "MODULE_SIG" = "y";

          "PARTITION_ADVANCED" = "y";
          "PRINTK_TIME" = "y";
          "SQUASHFS" = "y";
          "SQUASHFS_XZ" = "y";
        };
      };
    };
}
