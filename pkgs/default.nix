{ inputs, pkgs, system }:
let
  inherit (pkgs) callPackage;
in
{
  simnix = {
    scalcy = inputs.scalcy.packages.${system}.default;
    firefox-extensions = callPackage ./applications/networking/browsers/firefox/extensions.nix { };
  };
}
