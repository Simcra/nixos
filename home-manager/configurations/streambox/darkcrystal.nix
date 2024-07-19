{ pkgs, ... }:
{
  imports = [ ../../homes/darkcrystal.nix ];

  # Add extra packages
  home.packages = with pkgs; [
    spotify
  ];
}
