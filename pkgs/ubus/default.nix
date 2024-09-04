{ stdenv, lib, fetchFromGitHub, cmake, libubox, json_c }:
stdenv.mkDerivation {
  pname = "ubus";
  version = "unstable-04-09-2024";

  src = fetchFromGitHub {
    owner = "openwrt";
    repo = "ubus";
    rev = "65bb027054def3b94a977229fd6ad62ddd32345b";
    hash = "sha256-n82Ub0IiuvWbnlDCoN+0hjo/1PbplEbc56kuOYMrHxQ=";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    libubox
    json_c
  ];

  cmakeFlags = [
    "-DBUILD_LUA=off"
    "-DBUILD_EXAMPLES=off"
  ];
}
