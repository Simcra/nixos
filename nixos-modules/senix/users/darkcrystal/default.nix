{ config, lib, ... }:
let
  inherit (lib)
    mkEnableOption
    mkDefault
    mkIf;
  username = "darkcrystal";
  cfg = config.senix.users.${username};
  cfgHomeManager = config.senix.home-manager;
in
{
  options.senix.users.${username} = {
    enable = mkEnableOption {
      default = false;
      description = "Enables the '${username}' user account";
    };
  };

  config = {
    # Configure defaults
    senix.users.${username} = {
      enable = mkDefault false;
    };

    # Configure the NixOS user
    users.users.${username} = mkIf cfg.enable {
      isNormalUser = true;
      description = "Dark Crystal";
      extraGroups = [ "networkmanager" ];
    };

    # Configure Home Manager
    home-manager.users.${username} = mkIf (cfg.enable && cfgHomeManager.enable) (import ./home.nix);
  };
}
