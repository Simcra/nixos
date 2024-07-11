{ config, lib, ... }:
let
  inherit (lib)
    mkEnableOption
    mkDefault
    mkIf;
  cfg = config.senix.firewall;
in
{
  options.senix.firewall = {
    allowSpotify = mkEnableOption {
      default = false;
      description = "Open network ports for Spotify local discovery";
    };

    allowSteam = mkEnableOption {
      default = false;
      description = "Open network ports for Steam local network transfer and client discovery";
    };
  };

  config = {
    # Configure defaults
    senix.firewall = {
      allowSpotify = mkDefault false;
      allowSteam = mkDefault false;
    };

    networking.firewall = (mkIf cfg.allowSpotify {
      # Spotify local discovery
      allowedTCPPorts = [ 57621 ];
      allowedUDPPorts = [ 5353 ];
    }) // (mkIf cfg.allowSteam {
      # Steam local network transfer
      allowedTCPPorts = [ 27040 ];
      # Steam client discovery
      allowedUDPPortRanges = [{ from = 27031; to = 27036; }];
    });
  };
}
