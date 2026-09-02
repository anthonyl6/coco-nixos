{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  electron_39,
  makeWrapper,
  _7zz,
  python3,
  pkg-config,
  nodejs,
}:

buildNpmPackage rec {
  pname = "clone-hero-chart-manager";
  version = "1.3.3";

  src = fetchFromGitHub {
    owner = "xlzipx";
    repo = "clone-hero-chart-manager";
    rev = "v${version}";
    hash = "sha256-XXhFkUc05MUea8zemsJnGwHsVH5sWecP4XbX4FjeYLE=";
  };

  sourceRoot = "${src.name}/app";

  npmDepsHash = "sha256-mRZUH1UYlI89gNXgGFPM0Ln6Gh48wjh+jQaFsoe2caM=";

  env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  makeCacheWritable = true;

  nativeBuildInputs = [
    makeWrapper
    python3
    pkg-config
  ];

  # Skip the postinstall that tries to download better-sqlite3 prebuilds
  npmFlags = [ "--ignore-scripts" ];

  postConfigure = ''
    # Rebuild better-sqlite3 for the system Node.js ABI
    cd node_modules/better-sqlite3
    ${nodejs}/bin/npx --yes node-gyp rebuild --release \
      --nodedir=${nodejs}/include/node
    cd ../..
  '';

  buildPhase = ''
    runHook preBuild
    npx electron-vite build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/chm
    cp -r out $out/lib/chm/
    cp package.json $out/lib/chm/
    cp -r node_modules $out/lib/chm/

    mkdir -p $out/bin
    makeWrapper ${electron_39}/bin/electron $out/bin/clone-hero-chart-manager \
      --add-flags $out/lib/chm \
      --prefix PATH : ${lib.makeBinPath [ _7zz ]}

    # Desktop entry
    mkdir -p $out/share/applications
    cat > $out/share/applications/clone-hero-chart-manager.desktop <<EOF
    [Desktop Entry]
    Name=Clone Hero Chart Manager
    Comment=Search, download and convert Clone Hero charts
    Exec=clone-hero-chart-manager %U
    Icon=clone-hero-chart-manager
    Type=Application
    Categories=Game;Utility;
    Terminal=false
    EOF

    # Icon
    mkdir -p $out/share/icons/hicolor/256x256/apps
    cp build/icon.png $out/share/icons/hicolor/256x256/apps/clone-hero-chart-manager.png

    runHook postInstall
  '';

  meta = {
    description = "Search, download and convert Clone Hero and YARG charts";
    homepage = "https://github.com/xlzipx/clone-hero-chart-manager";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "clone-hero-chart-manager";
  };
}
