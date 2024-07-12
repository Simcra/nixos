{ config, lib, pkgs, ... }:
let
  inherit (lib)
    mkEnableOption
    mkDefault
    mkForce
    mkIf;
  cfg = config.senix.software.steam;
in
{
  options.senix.software.steam = {
    enable = mkEnableOption {
      default = false;
      description = "Enable the Steam game launcher";
    };

    enableGameScope = mkEnableOption {
      default = true;
      description = "Enable Steam GameScope";
    };

    enableRemotePlay = mkEnableOption {
      default = true;
      description = "Open network ports for Steam RemotePlay";
    };

    enableDedicatedServer = mkEnableOption {
      default = false;
      description = "Open network ports for Steam Dedicated Server";
    };

    enableGamemode = mkEnableOption {
      default = true;
      description = ''
        Enable the gamemode binaries for use with Steam.
        Add 'gamemoderun' to the game launch options in Steam to use.
      '';
    };

    enableMangoHUD = mkEnableOption {
      default = true;
      description = ''
        Enable mangohud for monitoring performance metrics.
        Add 'mangohud' to the game launch options in Steam to use.
      '';
    };
  };

  config = {
    # Configure defaults
    senix.software.steam = {
      enable = mkDefault false;
      enableGameScope = mkDefault cfg.enable;
      enableRemotePlay = mkDefault cfg.enable;
      enableDedicatedServer = mkDefault false;
      enableGamemode = mkDefault cfg.enable;
      enableMangoHUD = mkDefault cfg.enable;
    };

    # Trigger local network ports to be opened for steam
    senix.firewall.allowSteam = mkIf cfg.enable (mkForce true);

    # Enable and configure Steam
    programs.steam = mkIf cfg.enable {
      enable = mkDefault true;
      remotePlay.openFirewall = mkDefault cfg.enableRemotePlay;
      dedicatedServer.openFirewall = mkDefault cfg.enableDedicatedServer;
      gamescopeSession.enable = mkDefault cfg.enableGameScope;
    };

    # Enable and configure Gamemode
    programs.gamemode = mkIf (cfg.enable && cfg.enableGamemode) {
      enable = mkDefault true;
      enableRenice = mkDefault true;
    };

    # Enable MangoHUD
    environment.systemPackages = [
      (mkIf (cfg.enable && cfg.enableMangoHUD) pkgs.mangohud)
    ];
  };
}
