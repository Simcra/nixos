{ config, lib, pkgs, ... }:
let
  inherit (lib)
    mkEnableOption
    mkDefault
    mkIf;
  cfg = config.std.software.steam;
in
{
  options.std.software.steam = {
    enable = mkEnableOption {
      default = false;
      description = "Enable the Steam game launcher";
    };

    enableGameScope = mkEnableOption {
      default = cfg.enable;
      description = "Enable Steam GameScope";
    };

    enableRemotePlay = mkEnableOption {
      default = cfg.enable;
      description = "Open network ports for Steam RemotePlay";
    };

    enableDedicatedServer = mkEnableOption {
      default = false;
      description = "Open network ports for Steam Dedicated Server";
    };

    enableGamemode = mkEnableOption {
      default = cfg.enable;
      description = ''
        Enable the gamemode binaries for use with Steam.
        Add 'gamemoderun' to the game launch options in Steam to use.
      '';
    };

    enableMangoHUD = mkEnableOption {
      default = cfg.enable;
      description = ''
        Enable mangohud for monitoring performance metrics.
        Add 'mangohud' to the game launch options in Steam to use.
      '';
    };
  };

  config = mkIf cfg.enable {
    # Trigger local network ports to be opened for steam
    std.networks.local.enableSteam = mkDefault true;

    # Enable and configure Steam
    programs.steam = {
      enable = mkDefault true;
      gamescopeSession.enable = mkDefault cfg.enableGameScope;
      remotePlay.openFirewall = mkDefault cfg.enableRemotePlay;
      dedicatedServer.openFirewall = mkDefault cfg.enableDedicatedServer;
    };

    # Enable and configure Gamemode
    programs.gamemode = mkIf cfg.enableGamemode {
      enable = mkDefault true;
      enableRenice = mkDefault true;
    };

    # Enable MangoHUD
    environment.systemPackages = mkIf cfg.enableMangoHUD [ pkgs.mangohud ];
  };
}
