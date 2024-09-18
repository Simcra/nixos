{ pkgs, ... }:
{
  imports = [ ../../homes/simcra.nix ];

  # Add extra packages
  home.packages = with pkgs; [
    minetest
    scalcy # Add SCalcy for testing
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
