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
    package = pkgs.unstable.vscode.fhs;
    extensions =
      (with pkgs.vscode-extensions; [
        vadimcn.vscode-lldb # LLDB debugging support for C++, Rust and other compiled languages
      ])
      ++ (with pkgs.vscode-marketplace; [
        mkhl.direnv # Support loading and unloading of direnv within VSCode
        cweijan.vscode-database-client2 # Database client within vscode for convenience
        # Remote development support
        ms-vscode-remote.remote-ssh
        ms-vscode.remote-server
        ms-vscode-remote.remote-containers
        # Nix
        jnoortheen.nix-ide
        # C/C++
        ms-vscode.cpptools
        # Embedded development
        platformio.platformio-ide
        stmicroelectronics.stm32-vscode-extension
        # Rust
        rust-lang.rust-analyzer
        fill-labs.dependi
        njpwerner.autodocstring
        # Java
        redhat.java
        vscjava.vscode-java-debug
        vscjava.vscode-java-test
        vscjava.vscode-maven
        vscjava.vscode-gradle
        vscjava.vscode-java-dependency
        visualstudioexptteam.vscodeintellicode
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

      # Other extension settings
      "database-client.autoSync" = true;
      "redhat.telemetry.enabled" = false;
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
