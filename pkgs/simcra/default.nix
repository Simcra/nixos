{ pkgs, ... }:
{
  scalcy = pkgs.callPackage ./scalcy.nix { };
}
