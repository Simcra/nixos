{ pkgs, ... }:
{
  imports = [ ../. ];

  # Configure Home
  home = {
    username = "darkcrystal";
    homeDirectory = "/home/darkcrystal";
    packages = with pkgs; [
      vlc
    ];
  };
}
