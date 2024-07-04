{ pkgs, ... }:
{
  slint-rust-calculator = pkgs.callPackage ./slint-rust-calculator.nix { };
}
