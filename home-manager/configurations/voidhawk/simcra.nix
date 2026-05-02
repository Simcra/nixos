{ pkgs, ... }:
{
  imports = [
    ../../homes/simcra/.
    ../../homes/simcra/mangohud.nix
    ../../homes/simcra/vscode.nix
  ];

  # Add extra packages
  home.packages = with pkgs; [
    grsync
  ];
}
