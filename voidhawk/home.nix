{ pkgs, ... }: {
  home.packages = [
    pkgs.htop
  ];

  # Firefox
  programs.firefox = {
    enable = true;
    package = pkgs.firefox;
  };
  
  # VSCode with extensions
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      ms-azuretools.vscode-docker
      ms-python.python
      ms-vscode.cpptools
      ms-vscode-remote.remote-ssh
      # Nix
      bbenoist.nix
      # Lua
      sumneko.lua
      # Rust
      rust-lang.rust-analyzer
      serayuzgur.crates
      njpwerner.autodocstring      
    ];
  };
}
