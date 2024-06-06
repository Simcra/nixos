{ pkgs, ... }: {
  home.packages = [
    pkgs.htop
  ];
  
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

  # Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    extraPkgs = pkgs: [ glxinfo ];
  };
}
