{ pkgs, ... }:
{
  imports = [ ../../homes/simcra.nix ];

  # Add extra packages
  home.packages = with pkgs; [
    grsync
    minetest
    prismlauncher # Minecraft launcher
    nixfmt-rfc-style
    vesktop # Discord client
  ];

  # Configure VSCodium
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    extensions =
      (with pkgs.vscode-extensions; [
        mkhl.direnv
        jnoortheen.nix-ide
        ms-vscode-remote.remote-ssh
        vadimcn.vscode-lldb
        # Lua
        sumneko.lua
        # Rust
        rust-lang.rust-analyzer
        serayuzgur.crates
        njpwerner.autodocstring
      ])
      ++ (with pkgs.vscode-marketplace; [
        # slint.slint
      ]);
    userSettings = {
      # Enable nix LSP
      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "nixd";
      "nix.serverSettings" = {
        nixd.formatting.command = [ "nixfmt" ];
      };

      # Make rust-analyzer use the binary on the path rather than the bundled one
      "rust-analyzer.server.path" = "rust-analyzer";

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
