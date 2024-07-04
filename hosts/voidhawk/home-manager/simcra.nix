{ outputs, pkgs, ... }@specialArgs:
{
  imports = [ outputs.homeManagerTemplates.simcra ];

  home = {
    packages = with pkgs; [
      grsync
      minetest
      spotify
      vesktop
    ];
  };

  # Configure VSCodium
  programs.vscode = {
    extensions = (with pkgs.vscode-extensions; [
      ms-python.python
      ms-vscode.cpptools
      ms-vscode-remote.remote-ssh
      vadimcn.vscode-lldb
      # Lua
      sumneko.lua
      # Rust
      rust-lang.rust-analyzer
      serayuzgur.crates
      njpwerner.autodocstring
    ]) ++ (with pkgs.vscode-marketplace; [
      slint.slint
    ]);
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
