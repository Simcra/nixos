{
  lib,
  pkgs,
  overlays,
  ...
}:
let
  inherit (lib)
    mkDefault
    mkForce
    ;
in
{
  # Configure nix
  nix = {
    settings = {
      auto-optimise-store = mkDefault true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
    gc = {
      automatic = mkDefault true;
      dates = mkDefault "daily";
      options = mkDefault "--delete-older-than 14d";
    };
    channel.enable = mkDefault false;
  };

  # Configure nixpkgs
  nixpkgs = {
    config.allowUnfree = mkDefault true; # Allow proprietary packages to be installed
    overlays = with overlays; [
      # From inputs
      nur
      vscode-extensions
      # Custom overlays
      nixpkgs-overrides
      nixpkgs-unstable
    ];
  };

  # Configure home-manager
  home-manager = {
    useGlobalPkgs = mkDefault true;
    useUserPackages = mkDefault true;
    extraSpecialArgs = { inherit overlays; };
  };

  # Set default state version
  system.stateVersion = mkDefault "25.11";

  # Configure hardware
  hardware = {
    enableRedistributableFirmware = mkDefault true;
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

  # Configure default locale
  time.timeZone = mkDefault "Australia/Adelaide";
  i18n = rec {
    defaultLocale = mkDefault "en_AU.UTF-8";
    extraLocaleSettings = mkDefault {
      LC_ADDRESS = defaultLocale;
      LC_IDENTIFICATION = defaultLocale;
      LC_MEASUREMENT = defaultLocale;
      LC_MONETARY = defaultLocale;
      LC_NAME = defaultLocale;
      LC_NUMERIC = defaultLocale;
      LC_PAPER = defaultLocale;
      LC_TELEPHONE = defaultLocale;
      LC_TIME = defaultLocale;
    };
  };

  # Configure services
  services = {
    xserver = {
      enable = mkDefault true;
      excludePackages = with pkgs; [ xterm ]; # Why is xterm installed by default...
      xkb = {
        layout = mkDefault "au";
        variant = mkDefault "";
      };
    };

    desktopManager.gnome.enable = mkDefault true;
    displayManager.gdm = {
      enable = mkDefault true;
      autoSuspend = mkForce false; # Turn off autosuspend, grumble grumble
    };

    pipewire = {
      enable = mkDefault true;
      audio.enable = mkDefault true;
      pulse.enable = mkDefault true; # Enable pulseaudio integrations
      alsa = {
        enable = mkDefault true; # Enable alsa integrations
        support32Bit = mkDefault true;
      };
      jack.enable = mkDefault true; # Enable JACK integrations
      wireplumber.enable = mkDefault true;
    };

    pulseaudio.enable = mkDefault false;

    openssh = {
      enable = mkDefault true;
      settings = {
        PermitRootLogin = mkDefault "no"; # Disable root login
        PasswordAuthentication = mkDefault false; # Only allow login with SSH tokens
      };
    };

    onedrive = {
      enable = mkDefault false; # Enable OneDrive file sync daemon
      package = pkgs.unstable.onedrive; # Need to use the latest version for compatibility
    };
    printing.enable = mkDefault true; # Enable printing daemon
    fstrim.enable = mkDefault true; # Enable fstrim for trimming SSD space
  };

  # Configure programs
  programs = {
    direnv.enable = mkDefault true; # Enable direnv for easy development
  };

  # Configure default environment
  environment = {
    gnome.excludePackages = with pkgs; [ gnome-tour ];
    systemPackages = with pkgs; [
      curl
      htop
      nixd
      nixfmt-rfc-style
      nmon # Useful tool for monitoring system performance metrics
      pavucontrol # Allows more customization over audio sources and sinks
      wget
    ];
  };

  # Fonts
  fonts.packages = builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);
}
