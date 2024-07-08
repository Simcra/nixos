{ self, inputs, outputs, lib, pkgs, ... }:
{
  imports = [
    # Import nixosModules
    inputs.nur.nixosModules.nur
    inputs.home-manager.nixosModules.home-manager
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

  # Configure networking
  networking.networkmanager.enable = lib.mkDefault true;
  networking.useDHCP = lib.mkDefault true;

  # Configure desktop environment and window manager - Assuming all systems use X11/XServer and GNOME setup for now
  services.xserver = {
    enable = lib.mkDefault true;
    displayManager.gdm.enable = lib.mkDefault true;
    displayManager.gdm.autoSuspend = lib.mkDefault false; # *grumble grumble* autosuspend... 
    desktopManager.gnome.enable = lib.mkDefault true;
  };

  # Configure sound - We use Pipewire since it is the most developed
  hardware.pulseaudio.enable = lib.mkForce false;
  security.rtkit.enable = lib.mkDefault true;
  services.pipewire = {
    enable = lib.mkDefault true;
    audio.enable = lib.mkDefault true;
    pulse.enable = lib.mkDefault true;
    alsa = {
      enable = lib.mkDefault true;
      support32Bit = lib.mkDefault true;
    };
    jack.enable = lib.mkDefault true;
  };

  # Enable printing
  services.printing.enable = lib.mkDefault true;

  # Enable direnv
  programs.direnv.enable = lib.mkDefault true;

  # Enable fstrim - useful for trimming unused space from SSDs
  services.fstrim.enable = lib.mkDefault true;

  # Configure OpenSSH
  services.openssh = {
    enable = lib.mkDefault true;
    settings = {
      PermitRootLogin = lib.mkDefault "no";
      PasswordAuthentication = lib.mkDefault false;
    };
  };

  # Enable redistributable firmware
  hardware.enableRedistributableFirmware = lib.mkDefault true;
}
