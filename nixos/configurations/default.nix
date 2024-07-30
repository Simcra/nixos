{ lib, pkgs, overlays, ... }@specialArgs:
let
  inherit (lib)
    mkForce
    mkDefault;
in
{
  imports = import ../modules/module-list.nix;

  # Configure nix
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
    };
    gc = {
      automatic = mkDefault true;
      dates = mkDefault "weekly";
      options = mkDefault "--delete-older-than 14d";
    };
    channel.enable = mkDefault false;
  };

  # Configure nixpkgs
  nixpkgs = {
    config.allowUnfree = mkDefault true; # Allow proprietary packages to be installed
    overlays = with overlays.nixpkgs; [
      # From inputs
      vscode-extensions
      nur
      # Custom overlays
      packages
      fixes
      unstable
    ];
  };

  # Configure home-manager
  home-manager = {
    useGlobalPkgs = mkDefault true;
    useUserPackages = mkDefault true;
    extraSpecialArgs = { inherit overlays; };
  };

  # Use latest linux kernel by default
  boot.kernelPackages = mkDefault pkgs.linuxPackages_latest;

  # Set default state version
  system.stateVersion = mkDefault "24.05";

  # Configure hardware
  hardware = {
    enableRedistributableFirmware = mkDefault true;
    pulseaudio.enable = mkForce false;
  };

  # Configure networking 
  networking = {
    useDHCP = mkDefault true; # Use DHCP by default
    networkmanager.enable = mkDefault true; # Use networkmanager
  };

  # Configure security
  security = {
    rtkit.enable = mkDefault true;
  };

  # Configure services
  services = {
    xserver = {
      enable = mkDefault true; # Use X11
      displayManager.gdm = {
        enable = mkDefault true; # Use GDM display manager
        autoSuspend = mkDefault false; # Turn off autosuspend, grumble grumble
      };
      desktopManager.gnome.enable = mkDefault true; # Use GNOME desktop manager
    };

    pipewire = {
      enable = mkDefault true; # Use Pipewire audio service
      audio.enable = mkDefault true;
      pulse.enable = mkDefault true; # Enable pulseaudio integrations
      alsa = {
        enable = mkDefault true; # Enable alsa integrations
        support32Bit = mkDefault true;
      };
      jack.enable = mkDefault true; # Enable JACK integrations
    };

    openssh = {
      enable = mkDefault true; # Enable OpenSSH
      settings = {
        PermitRootLogin = mkDefault "no"; # Disable root login
        PasswordAuthentication = mkDefault false; # Only allow login with SSH tokens
      };
    };

    printing.enable = mkDefault true; # Enable printing daemon
    fstrim.enable = mkDefault true; # Enable fstrim for trimming SSD space
  };

  # Configure programs
  programs = {
    direnv.enable = mkDefault true; # Enable direnv by default
  };
}
