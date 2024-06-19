{ ... }:
{
  # Configure firewall to allow local discovery within the network, to actually install spotify, use home-manager package
  networking.firewall = {
    allowedTCPPorts = [ 57621 ];
    allowedUDPPorts = [ 5353 ];
  };
}
