{ ... }:
{
  imports = [
    ./wireguard.nix
    ./hosts.nix
  ];
  networking.wireguard.interfaces.asluni.ips = [ "172.16.2.12/32" ];
}
