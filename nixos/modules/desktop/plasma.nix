{
  config,
  lib,
  pkgs,
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

    environment.systemPackages = with pkgs; [
      kdePackages.filelight
      kdePackages.isoimagewriter
      kdePackages.kamoso
      kdePackages.kcalc
      kdePackages.kcharselect
      kdePackages.kclock
      kdePackages.kolourpaint
      kdePackages.krdc
      kdePackages.krfb
      kdePackages.ksystemlog
      kdePackages.kweather
      kdePackages.partitionmanager
      kdePackages.print-manager
    ];
  };
}
