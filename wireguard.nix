{ automous-zones, ... } : {
  networking.wireguard.interfaces.asluni = let
    peers = automous-zones.flakeModules.asluni.wireguard.networks.asluni.peers.by-name;
    azlib = automous-zones.lib;
  in {
    privateKeyFile = "/var/lib/wireguard/key";
    generatePrivateKeyFile = true;
    peers = azlib.toNonFlakeParts peers;
  };
}
