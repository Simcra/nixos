pkgs:
let
  inherit (pkgs) callPackage;
in
{
  simcra = {
    scalcy = callPackage ./applications/science/math/scalcy/default.nix { };
    firefox-extensions = callPackage ./applications/networking/browsers/firefox/extensions.nix { };
  };
}
