{ self, inputs, outputs, ... }:
{
  imports = [
    # Import Home Manager nixosModules
    inputs.home-manager.nixosModules.home-manager
    # Import NUR nixosModules
    inputs.nur.nixosModules.nur
  ];

  # Set state version
  system.stateVersion = "24.05";

  # Configure nix
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    channel.enable = false;
  };

  # Configure nixpkgs
  nixpkgs = {
    # Allow proprietary packages to be installed
    config.allowUnfree = true;
    # Configure overlays
    overlays = [
      # Add the VSCode and NUR overlays
      inputs.vscode-extensions.overlays.default
      inputs.nur.overlay

      # Add the overlays exported in overlays dir
      outputs.overlays.custom-packages
      outputs.overlays.modified-packages
      outputs.overlays.unstable-packages
    ];
  };

  # Configure Home Manager
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit self inputs outputs; };
  };

  # Configure desktop environment and window manager - Assuming all systems use X11/XServer and GNOME setup for now
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.autoSuspend = false;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure sound - Assuming all systems use Pipewire with ALSA setup for now
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
    jack.enable = true;
  };

  # Enable printing
  services.printing.enable = true;

  # Enable RealtimeKit system service
  security.rtkit.enable = true;
}
