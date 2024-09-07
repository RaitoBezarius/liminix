{
  lib,
  stdenv,
  fetchFromGitea,
  ubus,
  libubox,
  lua5_3,
  libnl-tiny,
  backend ? "nl80211"
}:
let
  lua = lua5_3;
in
stdenv.mkDerivation rec {
  pname = "iwinfo";
  version = "unstable-07-09-2024";

  src = fetchFromGitea {
    domain = "git.dgnum.eu";
    owner = "DGNum";
    repo = "iwinfo";
    rev = "14685a26805155aa5c137993b9a4861a0bc585d5";
    hash = "sha256-lg4sBoYcFFLhcUv+wKR6u1OCartjtnAoF9M5FdfO6JE=";
  };

  BACKENDS = backend;

  buildInputs = [
    ubus
    libubox
    lua
    libnl-tiny
  ];

  CFLAGS = "-I${libnl-tiny}/include/libnl-tiny -D_GNU_SOURCE";

  installPhase = ''
    runHook preInstall

    install -Dm755 iwinfo $out/bin/iwinfo
    install -Dm755 iwinfo.so $out/lib/lua/${lua.luaversion}/iwinfo.so
    install -Dm755 libiwinfo.so $out/lib/libiwinfo.so
    install -Dm755 libiwinfo.so.0 $out/lib/libiwinfo.so.0

    mkdir -p $out/include
    cp -r include/* $out/include

    runHook postInstall
  '';

  meta = {
    description = "Library to access wireless devices";
    homepage = "https://github.com/openwrt/iwinfo";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ raitobezarius ];
    mainProgram = "iwinfo";
    platforms = lib.platforms.all;
  };
}
