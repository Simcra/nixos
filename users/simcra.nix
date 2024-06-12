{ pkgs, ... }@args:
{
  # NixOS user
  users.users.simcra = {
    isNormalUser = true;
    description = "simcra";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    # packages = with pkgs; [];
  };

  # Ports used by Spotify for local network discovery
  networking.firewall = {
    allowedTCPPorts = [ 57621 ];
    allowedUDPPorts = [ 5353 ];
  };

  # Home Manager configuration
  home-manager.users.simcra = {
    home = {
      stateVersion = "24.05";
      packages = with pkgs; [
        discord
        htop
        minetest
        nil
        nixpkgs-fmt
        spotify
        vim
        wget
      ];
    };

    # Git
    programs.git = {
      enable = true;
      userName = "Simcra";
      userEmail = "simcra@live.com";
    };

    # Firefox
    programs.firefox = {
      enable = true;
      package = pkgs.firefox;
      profiles.default = {
        extensions =
          let
            firefox-addons = pkgs.nur.repos.rycee.firefox-addons;
            firefox-custom-addons = import ../home-manager/firefox-custom-addons.nix args;
          in
          [
            firefox-addons.ublock-origin
            firefox-custom-addons.nordpass-password-management
          ];
      };
    };

    # VSCode with extensions
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
      ]) ++ (with pkgs.vscode-marketplace; [ slint.slint ]);
      userSettings = {
        # Enable nix LSP
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nil";

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
  };
}
