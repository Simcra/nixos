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
      nixd
      nixpkgs-fmt
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

  # Configure VSCodium
  programs.vscode = {
    enable = true;
    package = pkgs.unstable.vscodium;
    extensions = (with pkgs.vscode-extensions; [
      # Standard for all VSCode installs
      jnoortheen.nix-ide
      mkhl.direnv
    ]);
    userSettings = {
      # Enable nix LSP
      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "nixd";

      # Use nixpkgs-fmt
      "nix.serverSettings" = {
        nil.formatting.command = [ "nixpkgs-fmt" ];
      };

      # Move that stupid sidebar to the right side, why is it on the left by default?
      "workbench.sideBar.location" = "right";

      # Show whitespace changes in diffs
      "diffEditor.ignoreTrimWhitespace" = false;

      # Git settings
      "git.autofetch" = true;
      "git.confirmSync" = false;

      # Debugger
      "debug.allowBreakpointsEverywhere" = true;
    };
  };
}
