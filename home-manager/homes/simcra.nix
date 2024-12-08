{ lib, pkgs, ... }:
let
  rootDir = ../..;
  firefoxExtensions = import (rootDir + "/nixos/derivations/programs/firefox/extensions.nix") { inherit lib; inherit pkgs; };
in
{
  imports = [ ./. ];

  # Configure Home
  home = {
    username = "simcra";
    homeDirectory = "/home/simcra";
    packages = with pkgs; [
      spotify
      vlc
    ];
  };

  # Configure Git
  programs.git = {
    userName = "Simcra";
    userEmail = "5228381+Simcra@users.noreply.github.com";
  };

  # Configure Firefox extensions
  programs.firefox = {
    profiles.default.extensions = [
      firefoxExtensions.nordpass-password-management
    ];
  };
}
