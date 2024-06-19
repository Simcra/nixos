{ ... }:
{
  # Configure Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  # Configure Gamemode - Enables performance optimizations launch options are set to: "gamemoderun %command%"
  programs.gamemode = {
    enable = true;
    enableRenice = true;
  };
}
