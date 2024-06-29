{ pkgs, ... }:
{
  # Configure Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    gamescopeSession.enable = true;
  };

  # Configure Firewall rules
  networking.firewall = {
    allowedTCPPorts = [ 27040 ]; # Network transfer
    allowedUDPPortRanges = [{ from = 27031; to = 27036; }]; # Client discovery
  };

  # Configure Gamemode - Enables performance optimizations launch options are set to: "gamemoderun %command%"
  programs.gamemode = {
    enable = true;
    enableRenice = true;
  };

  # Add mangohud for performance metrics overlay
  environment.systemPackages = with pkgs; [
    mangohud # Add mangohud for performance metrics overlay
    bottles # WINE prefix manager for everything else, useful for running all kinds of windows .exe files
  ];
}
