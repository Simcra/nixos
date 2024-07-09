{ outputs, pkgs, ... }:
{
  imports = [ outputs.homeManagerTemplates.darkcrystal ];

  # Add extra packages for this system
  home.packages = with pkgs; [
    spotify
  ];
}
