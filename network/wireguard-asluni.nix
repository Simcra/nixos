{ inputs, ... }: {
  networking.wireguard.interfaces.asluni =
    let
      peers = inputs.automous-zones.flakeModules.asluni.wireguard.networks.asluni.peers.by-name;
      azlib = inputs.automous-zones.lib;
    in
    {
      privateKeyFile = "/var/lib/wireguard/key";
      generatePrivateKeyFile = true;
      peers = azlib.toNonFlakeParts peers;
    };
}
