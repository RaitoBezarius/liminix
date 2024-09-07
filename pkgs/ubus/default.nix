{ stdenv, fetchFromGitHub, cmake, libubox, json_c, lua5_1, defaultSocketLocation ? "/run/ubus/ubus.sock" }:
stdenv.mkDerivation {
  pname = "ubus";
  version = "unstable-04-09-2024";

  src = fetchFromGitHub {
    owner = "openwrt";
    repo = "ubus";
    rev = "65bb027054def3b94a977229fd6ad62ddd32345b";
    hash = "sha256-n82Ub0IiuvWbnlDCoN+0hjo/1PbplEbc56kuOYMrHxQ=";
  };

  # We don't use /var/run/ in Liminix by default.
  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "/var/run/ubus/ubus.sock" "${defaultSocketLocation}"
  '';

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    lua5_1
    libubox
    json_c
  ];

  cmakeFlags = [
    "-DBUILD_LUA=on"
    "-DLUAPATH=${placeholder "out"}/lib/lua"
    "-DBUILD_EXAMPLES=off"
  ];
}
