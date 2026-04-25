{ pkgs, ... }:
{
  networking = {
    firewall = {
      allowedTCPPorts = [ 57621 ];
      allowedUDPPorts = [ 5353 ];
    };
  };

  environment.systemPackages = with pkgs; [
    spotify
  ];
}
