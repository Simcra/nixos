{ pkgs, defaults, ... }:
{
  imports = [ defaults.homes.darkcrystal ];

  # Add extra packages for this system
  home.packages = with pkgs; [
    spotify
  ];
}
