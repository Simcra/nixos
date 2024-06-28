{ outputs, pkgs, ... }@args:
{
  imports = [ ./common.nix ];

  home = {
    username = "simcra";
    homeDirectory = "/home/simcra";
    packages = with pkgs; [
      vesktop
      grsync
      htop
      minetest
      unstable.nixd
      nixpkgs-fmt
      spotify
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
          firefox-extensions = outputs.homeManagerModules.firefox-custom-addons args;
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
      ms-azuretools.vscode-docker
      ms-python.python
      ms-vscode.cpptools
      ms-vscode-remote.remote-ssh
      eamodio.gitlens
      vadimcn.vscode-lldb
      # Nix
      jnoortheen.nix-ide
      # Lua
      sumneko.lua
      # Rust
      rust-lang.rust-analyzer
      serayuzgur.crates
      njpwerner.autodocstring
      # Nix shenanigans
      mkhl.direnv
    ]) ++ (with pkgs.vscode-marketplace; [
      slint.slint
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

  # Configure MangoHUD
  programs.mangohud = {
    enable = true;
    enableSessionWide = true;
    settings = {
      full = true;
      no_display = true;
      cpu_load_change = true;
    };
  };
}
