{ pkgs, defaults, ... }:
{
  imports = [ defaults.homes.simcra ];

  # Add extra packages for Voidhawk VM
  home.packages = with pkgs; [
    minetest
    simcra.scalcy # Add SCalcy for testing
  ];

  # Configure VSCodium extensions
  programs.vscode.extensions = (with pkgs.vscode-extensions; [
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
}
