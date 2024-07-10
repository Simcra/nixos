{ inputs, config, lib, ... }:
let
  inherit (lib)
    mkOption
    mkEnableOption
    mkIf
    types;
  cfg = config.std.networks.asluni;
in
{
  options.std.networks.asluni = {
    enable = mkEnableOption {
      default = false;
      description = "Enable connectivity to the asluni wireguard network";
    };

    ipAddresses = mkOption {
      type = types.nonEmptyListOf types.str;
      description = "List of IP addresses of the current system";
    };
  };

  config = mkIf cfg.enable {
    # Configure the wireguard interface
    networking.wireguard.interfaces.asluni =
      let
        azLib = inputs.automous-zones.lib;
        azFlakeModules = inputs.automous-zones.flakeModules;
        azLuninet = azFlakeModules.asluni.wireguard.networks.asluni;
      in
      {
        privateKeyFile = "/var/lib/wireguard/key";
        generatePrivateKeyFile = true;
        peers = azLib.toNonFlakeParts azLuninet.peers.by-name;
        ips = cfg.ipAddresses;
      };

    # Configure the known hosts
    networking.hosts =
      let
        cypress = [
          "cypress.local"
          "sesh.cypress.local"
          "tape.cypress.local"
          "codex.cypress.local"
          "chat.cypress.local"
        ];
      in
      {
        "172.16.2.1" = cypress;
      };
  };
}
