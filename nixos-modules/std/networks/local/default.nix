{ config, lib, ... }:
let
  inherit (lib)
    mkEnableOption
    mkIf;
  cfg = config.std.networks.local;
in
{
  options.std.networks.local = {
    enableSpotify = mkEnableOption {
      default = false;
      description = "Open network ports for Spotify local discovery";
    };

    enableSteam = mkEnableOption {
      default = false;
      description = "Open network ports for Steam local network transfer and client discovery";
    };
  };

  config = {
    networking.firewall = (mkIf cfg.enableSpotify {
      # Spotify local discovery
      allowedTCPPorts = [ 57621 ];
      allowedUDPPorts = [ 5353 ];
    }) // (mkIf cfg.enableSteam {
      # Steam local network transfer
      allowedTCPPorts = [ 27040 ];
      # Steam client discovery
      allowedUDPPortRanges = [{ from = 27031; to = 27036; }];
    });
  };
}
