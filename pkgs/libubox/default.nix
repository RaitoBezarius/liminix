{
  lib,
  stdenv,
  fetchFromGitea,
  cmake,
  lua,
  json_c
}:

stdenv.mkDerivation rec {
  pname = "libubox";
  version = "unstable-2024-04-09";

  src = fetchFromGitea {
    domain = "git.dgnum.eu";
    owner = "DGNum";
    repo = "libubox";
    rev = "1c4b2dc4c12848e1b70b11e1cb2139ca8f19c860";
    hash = "sha256-aPhGJ7viXQmnoQRY8DuRvtwtxSy+S4qPj1fBsK066Yc=";
  };

  nativeBuildInputs = [
    cmake
    lua
  ];

  buildInputs = [
    lua
    json_c
  ];

  # Otherwise, CMake cannot find jsoncpp?
  env.NIX_CFLAGS_COMPILE = toString [ "-I${json_c.dev}/include/json-c" "-D JSONC" "-D LUA_COMPAT_MODULE" ];

  cmakeFlags = [
    "-DBUILD_EXAMPLES=off"
    # TODO: it explode at install phase.
    "-DBUILD_LUA=on"
    "-DLUAPATH=${placeholder "out"}/lib/lua/${lua.luaversion}/"
  ];

  meta = {
    description = "";
    homepage = "https://git.openwrt.org/project/libubox.git";
    maintainers = with lib.maintainers; [ raitobezarius ];
    mainProgram = "libubox";
    platforms = lib.platforms.all;
  };
}
