{ pkgs, ... }:
{
  imports = [ ./. ];

  # Configure Home
  home = {
    username = "darkcrystal";
    homeDirectory = "/home/darkcrystal";
    packages = with pkgs; [
      spotify
      vlc
    ];
  };
}
