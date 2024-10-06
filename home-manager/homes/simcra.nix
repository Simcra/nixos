{ pkgs, ... }:
{
  imports = [ ./. ];

  # Configure Home
  home = {
    username = "simcra";
    homeDirectory = "/home/simcra";
    packages = with pkgs; [
      htop
      nvim
      nixd
      nixpkgs-fmt
      wget
    ];
  };

  # Configure Git
  programs.git = {
    userName = "Simcra";
    userEmail = "5228381+Simcra@users.noreply.github.com";
  };

  # Configure Firefox extensions
  programs.firefox = {
    profiles.default.extensions = with pkgs.simcra.firefox-extensions; [
      nordpass-password-management
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
