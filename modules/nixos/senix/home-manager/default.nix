{ config, lib, overlays, homeManagerModules, ... }:
let
  inherit (lib)
    mkEnableOption
    mkDefault
    mkIf;
  cfg = config.senix.home-manager;
in
{
  options.senix.home-manager = {
    enable = mkEnableOption {
      default = true;
      description = "Enable Home Manager for this system";
    };
  };

  config = {
    # Configure defaults
    senix.home-manager = {
      enable = mkDefault true;
    };

    # Configure Home Manager
    home-manager = mkIf cfg.enable {
      useGlobalPkgs = mkDefault true;
      useUserPackages = mkDefault true;
      extraSpecialArgs = { inherit overlays homeManagerModules; };
    };
  };
}
