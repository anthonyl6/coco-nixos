{ lib, ... }:
{
  # Provide the Nix-managed defaults as a separate file; seed the real
  # settings.json only when it doesn't already exist so DMS changes persist.
  home.file.".config/DankMaterialShell/settings-nix.json" = {
    source = ../../../cfg/dms/settings.json;
  };

  home.file.".config/DankMaterialShell/themes" = {
    force = true;
    source = ../../../cfg/dms/themes;
    recursive = true;
  };

  home.activation.seedDmsSettings = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    settings="$HOME/.config/DankMaterialShell/settings.json"
    seed="$HOME/.config/DankMaterialShell/settings-nix.json"

    # Create from seed if missing or still a symlink from old Nix management
    if [ ! -f "$settings" ] || [ -L "$settings" ]; then
      $DRY_RUN_CMD mkdir -p "$(dirname "$settings")"
      $DRY_RUN_CMD cp "$seed" "$settings"
    fi
  '';
}
