{
  lib,
  stdenv,
  fetchurl,
  patchelf,
  glibc,
  libsecret,
  makeWrapper,
}:

stdenv.mkDerivation {
  pname = "proton-drive-cli";
  version = "0.7.0";

  src = fetchurl {
    url = "https://proton.me/download/drive/cli/0.7.0/linux-x64/proton-drive";
    hash = "sha256-Tjx0p6JdoA16DKnuIjqbewsjjaNXq2/P7gSlwxPd9NE=";
  };

  nativeBuildInputs = [ patchelf makeWrapper ];

  dontUnpack = true;
  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    install -Dm755 $src $out/bin/.proton-drive-unwrapped
    patchelf --set-interpreter ${glibc}/lib/ld-linux-x86-64.so.2 $out/bin/.proton-drive-unwrapped
    makeWrapper $out/bin/.proton-drive-unwrapped $out/bin/proton-drive \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ libsecret ]}
  '';

  meta = {
    description = "Proton Drive CLI for automating and scripting file operations";
    homepage = "https://proton.me/support/drive-cli";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "proton-drive";
  };
}
