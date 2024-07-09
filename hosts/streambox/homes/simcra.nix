{ pkgs, defaults, ... }:
{
  imports = [ defaults.homes.simcra ];

  # Add extra packages for this system
  home.packages = with pkgs; [
    spotify
  ];
}
