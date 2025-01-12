{ lib, pkgs, ... }:
let
  inherit (lib) mkDefault;
in
{
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

  # Enable Firefox with ublock origin extension
  programs.firefox = {
    enable = mkDefault true;
    profiles.default.extensions = with pkgs.nur.repos.rycee.firefox-addons; [ ublock-origin ];
  };

  # Nicely reload systemd units when changing configurations
  systemd.user.startServices = mkDefault "sd-switch";

  # Set the home-manager state version
  home.stateVersion = mkDefault "24.11";
}
