{ stdenv, fetchFromGitea, lib, cmake, libubox, json_c, lua, defaultSocketLocation ? "/run/ubus/ubus.sock" }:
stdenv.mkDerivation {
  pname = "ubus";
  version = "unstable-04-09-2024";

  src = fetchFromGitea {
    domain = "git.dgnum.eu";
    owner = "DGNum";
    repo = "ubus";
    rev = "ebb1dc92e4985538a8e18b7e926264118138f281";
    hash = "sha256-fo4zleC9R6uzlcOJ/jQ0t0nSBHUAq/uqPVd9xJdkAM0=";
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
    lua
    libubox
    json_c
  ];

  cmakeFlags = [
    "-DBUILD_LUA=on"
    "-DLUAPATH=${placeholder "out"}/lib/lua/${lua.luaversion}"
    "-DBUILD_EXAMPLES=off"
  ];
}
