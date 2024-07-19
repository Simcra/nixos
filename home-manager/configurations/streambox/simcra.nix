{ pkgs, ... }:
{
  imports = [ ../../homes/simcra.nix ];

  # Add extra packages
  home.packages = with pkgs; [
    simcra.scalcy # Add SCalcy for testing
    spotify
  ];
}
