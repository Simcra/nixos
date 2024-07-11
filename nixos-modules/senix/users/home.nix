# Beware, this is a home-manager module not a nixos module
{ lib, pkgs, ... }:
let
  inherit (lib) mkDefault;
in
{
  # Enable Home Manager
  programs.home-manager.enable = mkDefault true;

  # Enable Git
  programs.git.enable = mkDefault true;

  # Enable Firefox with ublock origin extension
  programs.firefox = {
    enable = mkDefault true;
    profiles.default.extensions = [ pkgs.nur.repos.rycee.firefox-addons.ublock-origin ];
  };

  # Nicely reload systemd units when changing configurations
  systemd.user.startServices = mkDefault "sd-switch";

  # Set the home-manager state version
  home.stateVersion = mkDefault "24.05";
}
