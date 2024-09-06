{ config, pkgs, lib, ... }:
let
  inherit (lib)
    mkEnableOption
    mkIf;
  cfg = config.programs.scalcy;
in
{
  options = {
    programs.scalcy.enable = mkEnableOption "SCalcy";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ simnix.scalcy ];
  };
}
