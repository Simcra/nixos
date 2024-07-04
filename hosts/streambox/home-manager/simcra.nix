{ outputs, pkgs, ... }:
{
  imports = [ outputs.homeManagerTemplates.simcra ];

  home = {
    packages = with pkgs; [
      spotify
    ];
  };
}
