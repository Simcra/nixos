{ azLib, azFlakeModules, ... }:
{
  networking = {
    wireguard.interfaces = {
      asluni = {
        privateKeyFile = "/var/lib/wireguard/asluni";
        generatePrivateKeyFile = true;
        peers = azLib.toNonFlakeParts azFlakeModules.asluni.wireguard.networks.asluni.peers.by-name;
        ips = [ "172.16.2.12/32" ];
      };
    };
    hosts =
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
