{ self, inputs, outputs, lib, ... }:
{
  imports = [
    # Import Home Manager nixosModules
    inputs.home-manager.nixosModules.home-manager
    # Import NUR nixosModules
    inputs.nur.nixosModules.nur
  ];

  # Set state version
  system.stateVersion = lib.mkDefault "24.05";

  # Configure nix
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
    };
    gc = {
      automatic = lib.mkDefault true;
      dates = lib.mkDefault "weekly";
      options = lib.mkDefault "--delete-older-than 14d";
    };
    channel.enable = lib.mkDefault false;
  };

  # Configure nixpkgs
  nixpkgs = {
    # Allow proprietary packages to be installed
    config.allowUnfree = lib.mkDefault true;
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
    useGlobalPkgs = lib.mkDefault true;
    useUserPackages = lib.mkDefault true;
    extraSpecialArgs = lib.mkDefault { inherit self inputs outputs; };
  };

  # Configure desktop environment and window manager - Assuming all systems use X11/XServer and GNOME setup for now
  services.xserver = {
    enable = lib.mkDefault true;
    displayManager.gdm = {
      enable = lib.mkDefault true;
      autoSuspend = lib.mkDefault false;
    };
    desktopManager.gnome.enable = lib.mkDefault true;
  };

  # Configure sound - Assuming all systems use Pipewire with ALSA setup for now
  hardware.pulseaudio.enable = lib.mkForce false;
  services.pipewire = {
    enable = lib.mkDefault true;
    alsa = {
      enable = lib.mkDefault true;
      support32Bit = lib.mkDefault true;
    };
    pulse.enable = lib.mkDefault true;
    jack.enable = lib.mkDefault true;
  };

  # Enable printing
  services.printing.enable = lib.mkDefault true;

  # Enable RealtimeKit system service
  security.rtkit.enable = lib.mkDefault true;
}
