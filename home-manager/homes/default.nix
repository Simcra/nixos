{ lib, pkgs, ... }:
let
  inherit (lib) mkDefault;
in
{
  # Default packages to install for every user
  home.packages = with pkgs; [
    brave
  ];

  # Configure GNOME
  dconf.settings = {
    "org/gnome/desktop/wm/preferences" = {
      button-layout = ":minimize,maximize,close";
    };
  };

  # Enable Git
  programs.git.enable = mkDefault true;

  # Nicely reload systemd units when changing configurations
  systemd.user.startServices = mkDefault "sd-switch";

  # Set the home-manager state version
  home.stateVersion = mkDefault "24.11";
}
