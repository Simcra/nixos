{ pkgs, ... }:
{
  imports = [ ../. ];

  # Configure Home
  home = {
    username = "simcra";
    homeDirectory = "/home/simcra";
    packages = with pkgs; [
      nixfmt-rfc-style
      transmission_4-qt
      vesktop
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
