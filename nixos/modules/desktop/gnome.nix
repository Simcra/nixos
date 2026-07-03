{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkForce;
in
{
  config = lib.mkIf (config.desktop.environment == "gnome") {
    services = {
      desktopManager.gnome.enable = true;
      displayManager.gdm = {
        enable = true;
        autoSuspend = mkForce false; # Turn off autosuspend, grumble grumble
      };
    };

    environment = {
      gnome.excludePackages = with pkgs; [
        epiphany # Web browser
        geary # Email client
        papers # Document viewer
        showtime # Video player

        # GNOME
        gnome-tour
      ];
    };
  };
}
