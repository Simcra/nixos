{ lib, pkgs, overlays, ... }@specialArgs:
let
  inherit (lib)
    mkForce
    mkDefault;
in
{
  config = {
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

    # Use latest linux kernel by defauft
    boot.kernelPackages = mkDefault pkgs.linuxPackages_latest;

    # Set default state version
    system.stateVersion = mkDefault "24.05";

    # Configure hardware
    hardware = {
      enableRedistributableFirmware = mkDefault true;

      # Configure pulseaudio
      pulseaudio.enable = mkForce false;
    };

    # Configure networking 
    networking = {
      useDHCP = mkDefault true; # Use DHCP by default

      # Configure networkmanager
      networkmanager.enable = mkDefault true;
    };

    # Configure security
    security = {
      # Configure realtime kit
      rtkit.enable = mkDefault true;
    };

    # Configure services
    services = {
      # Configure X11
      xserver = {
        enable = mkDefault true;
        displayManager.gdm = {
          enable = mkDefault true; # Use GDM display manager
          autoSuspend = mkDefault false; # Turn off autosuspend, grumble grumble
        };
        desktopManager.gnome.enable = mkDefault true; # Use GNOME desktop manager
      };

      # Configure Pipewire audio service
      pipewire = {
        enable = mkDefault true;
        audio.enable = mkDefault true;
        pulse.enable = mkDefault true; # Enable pulseaudio integrations
        alsa = {
          enable = mkDefault true; # Enable alsa integrations
          support32Bit = mkDefault true;
        };
        jack.enable = mkDefault true; # Enable JACK integrations
      };

      # Configure OpenSSH
      openssh = {
        enable = mkDefault true;
        settings = {
          PermitRootLogin = mkDefault "no"; # Disable root login
          PasswordAuthentication = mkDefault false; # Only allow login with SSH tokens
        };
      };

      # Configure printing
      printing.enable = mkDefault true;

      # Configure fstrim - useful tool for trimming space on SSDs
      fstrim.enable = mkDefault true;
    };

    # Configure programs
    programs = {
      # Configure direnv
      direnv.enable = mkDefault true;
    };
  };
}
