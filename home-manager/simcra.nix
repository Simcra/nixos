{ outputs, pkgs, ... }@specialArgs:
{
  imports = [ ./common.nix ];

  home = {
    username = "simcra";
    homeDirectory = "/home/simcra";
    packages = with pkgs; [
      htop
      unstable.nixd
      nixpkgs-fmt
      vim
      wget
    ];
  };

  # Configure Git
  programs.git = {
    userName = "Simcra";
    userEmail = "5228381+Simcra@users.noreply.github.com";
  };

  # Configure Firefox
  programs.firefox = {
    enable = true;
    package = pkgs.firefox;
    profiles.default = {
      extensions =
        let
          firefox-addons = pkgs.nur.repos.rycee.firefox-addons;
          firefox-extensions = outputs.homeManagerModules.firefox-custom-addons specialArgs;
        in
        [
          firefox-addons.ublock-origin
          firefox-extensions.nordpass-password-management
        ];
    };
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

      # Gitlens shenanigans
      "gitlens.graph.layout" = "editor";
      "gitlens.showWelcomeOnInstall" = false;
      "gitlens.showWhatsNewAfterUpgrades" = false;
    };
  };
}
