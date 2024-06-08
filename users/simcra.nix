{ pkgs, ... }: {
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
  networking.firewall.allowedTCPPorts = [ 57621 ];
  networking.firewall.allowedUDPPorts = [ 5353 ];

  # Home Manager configuration
  home-manager.users.simcra = {
    home.stateVersion = "24.05";
    home.packages = with pkgs; [
      discord
      htop
      nil
      nixpkgs-fmt
      spotify
      vim
      wget
    ];

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
        extensions = with pkgs.nur.repos.rycee.firefox-addons; [
          ublock-origin
        ];
      };
      policies = {
        ExtensionSettings = let 
          extension = shortId: uuid: {
            name = uuid;
            value = {
              install_url = "https://addons.mozilla.org/en-US/firefox/downloads/latest/${shortId}/latest.xpi";
              installation_mode = "normal_installed";
            };
          };
          in builtins.listToAttrs [
            (extension "nordpass-password-management" "nordpassStandalone@nordsecurity.com")
          ];
      };
    };

    # VSCode with extensions
    programs.vscode = {
      enable = true;
      package = pkgs.unstable.vscodium;
      extensions = with pkgs.vscode-extensions; [
        ms-azuretools.vscode-docker
        ms-python.python
        ms-vscode.cpptools
        ms-vscode-remote.remote-ssh
        # Nix
        jnoortheen.nix-ide
        # Lua
        sumneko.lua
        # Rust
        rust-lang.rust-analyzer
        serayuzgur.crates
        njpwerner.autodocstring
      ];
      userSettings = {
        # Nix LSP and formatter
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nil";
        "nix.serverSettings" = {
          "nil.formatting.command" = [ "nixpkgs-fmt" ];
        };

        # Move that stupid sidebar to the right side, why is it on the left by default?
        "workbench.sideBar.location" = "right";
      };
    };
  };
}
