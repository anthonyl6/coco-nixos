{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  glibc,
}:

stdenv.mkDerivation {
  pname = "proton-drive-cli";
  version = "0.7.0";

  src = fetchurl {
    url = "https://proton.me/download/drive/cli/0.7.0/linux-x64/proton-drive";
    hash = "sha256-Tjx0p6JdoA16DKnuIjqbewsjjaNXq2/P7gSlwxPd9NE=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ glibc ];

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    install -Dm755 $src $out/bin/proton-drive
  '';

  meta = {
    description = "Proton Drive CLI for automating and scripting file operations";
    homepage = "https://proton.me/support/drive-cli";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "proton-drive";
  };
}
