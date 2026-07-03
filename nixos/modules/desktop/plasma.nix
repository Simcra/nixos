{
  config,
  lib,
  ...
}:
{
  config = lib.mkIf (config.desktop.environment == "plasma") {
    services = {
      desktopManager.plasma6.enable = true;
      displayManager.sddm = {
        enable = true;
        wayland.enable = true;
      };
    };
  };
}
