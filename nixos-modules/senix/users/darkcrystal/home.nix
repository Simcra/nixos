{ ... }:
let
  username = "darkcrystal";
in
{
  imports = [
    ../home.nix
  ];

  # Configure Home
  home = {
    username = "${username}";
    homeDirectory = "/home/${username}";
  };
}
