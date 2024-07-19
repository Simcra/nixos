{ inputs }:
{
  nixpkgs = import ./nixpkgs.nix { inherit inputs; };
}
