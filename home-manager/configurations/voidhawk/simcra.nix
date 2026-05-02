{ pkgs, ... }:
{
  imports = [
    ../../homes/simcra/.
    ../../homes/simcra/vscode.nix
  ];

  # Add extra packages
  home.packages = with pkgs; [
    grsync
  ];
}
