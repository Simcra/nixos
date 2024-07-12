{ pkgs, ... }:
{
  # Add extra packages
  home.packages = with pkgs; [
    spotify
  ];
}
