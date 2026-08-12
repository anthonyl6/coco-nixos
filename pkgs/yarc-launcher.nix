{
  lib,
  appimageTools,
  fetchurl,
}:

let
  pname = "yarc-launcher";
  version = "1.3.0";

  src = fetchurl {
    url = "https://github.com/YARC-Official/YARC-Launcher/releases/download/v${version}/YARC.Launcher_${version}_amd64.AppImage";
    hash = "sha256-QObnI3DtgfiZ9GYBOboHatmdExvKvcp2SZo9zuu15VY=";
  };

  appimageContents = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm644 ${appimageContents}/yarc-launcher.desktop $out/share/applications/yarc-launcher.desktop
    substituteInPlace $out/share/applications/yarc-launcher.desktop \
      --replace-warn 'Exec=AppRun' 'Exec=yarc-launcher'
    cp -r ${appimageContents}/usr/share/icons $out/share/icons 2>/dev/null || true
  '';

  meta = {
    description = "Official launcher for YARG";
    homepage = "https://github.com/YARC-Official/YARC-Launcher";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "yarc-launcher";
  };
}
