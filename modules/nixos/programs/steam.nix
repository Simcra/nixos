{ pkgs, ... }:
{
  # Configure Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    gamescopeSession.enable = true;
  };

  # Configure Gamemode - Enables performance optimizations launch options are set to: "gamemoderun %command%"
  programs.gamemode = {
    enable = true;
    enableRenice = true;
  };

  # Add mangohud for performance metrics overlay
  environment.systemPackages = with pkgs; [
    mangohud
  ];
}
