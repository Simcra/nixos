{ inputs, ... }:
{
  # Configure the wireguard interface
  networking.wireguard.interfaces.asluni =
    let
      azLib = inputs.automous-zones.lib;
      azFlakeModules = inputs.automous-zones.flakeModules;
      asluniNetwork = azFlakeModules.asluni.wireguard.networks.asluni;
    in
    {
      privateKeyFile = "/var/lib/wireguard/key";
      generatePrivateKeyFile = true;
      peers = azLib.toNonFlakeParts asluniNetwork.peers.by-name;
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
}
