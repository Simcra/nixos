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
        vadimcn.vscode-lldb # LLDB debugging support for C++, Rust and other compiled languages
      ])
      ++ (with pkgs.vscode-marketplace; [
        mkhl.direnv # Support loading and unloading of direnv within VSCode
        ms-vscode-remote.vscode-remote-extensionpack # Support for remote development via ssh, tunnels and dev containers
        # Nix
        jnoortheen.nix-ide
        # C/C++
        ms-vscode.cpptools
        # Rust
        rust-lang.rust-analyzer
        serayuzgur.crates
        njpwerner.autodocstring
        # Java
        vscjava.vscode-java-pack
        # Lua
        sumneko.lua
        # Python
        ms-python.python
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
