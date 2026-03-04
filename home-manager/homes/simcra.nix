{ pkgs, ... }:
{
  imports = [ ./. ];

  # Configure Home
  home = {
    username = "simcra";
    homeDirectory = "/home/simcra";
    packages = with pkgs; [
      transmission_4-qt
      spotify
      vlc
    ];
  };

  # Configure Git
  programs.git = {
    settings.user = {
      name = "Simcra";
      email = "5228381+Simcra@users.noreply.github.com";
    };
  };
}
