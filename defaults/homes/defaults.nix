{ lib, pkgs, ... }:
{
  imports = [ ../nixpkgs.nix ];

  # Enable home manager
  programs.home-manager.enable = lib.mkDefault true;

  # Enable git and configure safe directory to prevent nasty git errors
  programs.git = {
    enable = lib.mkDefault true;
    extraConfig.safe.directory = lib.mkDefault "/etc/nixos/.git";
  };

  # Enable firefox with ublock origin extension
  programs.firefox = {
    enable = lib.mkDefault true;
    profiles.default.extensions = [ pkgs.nur.repos.rycee.firefox-addons.ublock-origin ];
  };

  # Nicely reload systemd units when changing configurations
  systemd.user.startServices = lib.mkDefault "sd-switch";

  # Set the home-manager state version
  home.stateVersion = lib.mkDefault "24.05";
}
