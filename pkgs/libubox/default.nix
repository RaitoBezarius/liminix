{
  lib,
  stdenv,
  fetchgit,
  cmake,
  lua5_1,
  json_c
}:

stdenv.mkDerivation rec {
  pname = "libubox";
  version = "unstable-2024-04-09";

  src = fetchgit {
    url = "https://git.openwrt.org/project/libubox.git";
    rev = "eb9bcb64185ac155c02cc1a604692c4b00368324";
    hash = "sha256-5KO2E+4pcDp/pe2+vjoQDmyMwCc0yKm847U4J6HjxyA=";
  };

  nativeBuildInputs = [
    cmake
    lua5_1
  ];

  buildInputs = [
    lua5_1
    json_c
  ];

  # Otherwise, CMake cannot find jsoncpp?
  env.NIX_CFLAGS_COMPILE = toString [ "-I${json_c.dev}/include/json-c" "-D JSONC" ];

  cmakeFlags = [
    "-DBUILD_EXAMPLES=off"
    # TODO: it explode at install phase.
    "-DBUILD_LUA=off"
  ];

  meta = {
    description = "";
    homepage = "https://git.openwrt.org/project/libubox.git";
    maintainers = with lib.maintainers; [ raitobezarius ];
    mainProgram = "libubox";
    platforms = lib.platforms.all;
  };
}
