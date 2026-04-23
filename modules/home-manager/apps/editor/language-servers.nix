{ pkgs-stable, ... }:
{
  home.packages = with pkgs-stable; [
    # TODO: most language servers are already being imported because of helix.
    # since we are now using helix here instead, we should move them over.
    nixd
  ];
}
