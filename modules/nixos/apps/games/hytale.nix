{
  stdenv,
  inputs,
  ...
}: {
  environment.systemPackages = [
    inputs.hytale.packages.${stdenv.hostPlatform.system}.default
  ];
}
