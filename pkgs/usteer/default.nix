{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  json_c,
  libpcap,
  libubox,
  ubus,
}:

stdenv.mkDerivation rec {
  pname = "usteer";
  version = "unstable-04-09-2024";

  src = fetchFromGitHub {
    owner = "openwrt";
    repo = "usteer";
    rev = "e218150979b40a1b3c59ad0aaa3bbb943814db1e";
    hash = "sha256-shbN5Wp7m/olr0OcckcPk11yXnJxpnllXqi/bw+X7gM=";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [ ubus libpcap libubox json_c ];

  meta = {
    description = "";
    homepage = "https://github.com/openwrt/usteer";
    maintainers = with lib.maintainers; [ raitobezarius ];
    mainProgram = "usteer";
    platforms = lib.platforms.all;
  };
}
