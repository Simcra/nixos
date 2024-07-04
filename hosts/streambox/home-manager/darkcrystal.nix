{ outputs, pkgs, ... }:
{
  imports = [ outputs.homeManagerTemplates.darkcrystal ];

  home = {
    packages = with pkgs; [
      spotify
    ];
  };
}
