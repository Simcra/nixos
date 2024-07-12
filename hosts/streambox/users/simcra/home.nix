{ pkgs, ... }:
{
  # Add extra packages
  home.packages = with pkgs; [
    scalcy # Add SCalcy for testing
    spotify
  ];
}
