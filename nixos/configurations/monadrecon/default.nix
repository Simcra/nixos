{ config, lib, pkgs, ... }:
let
  rootDir = ../../..;
  nvidiaPackages = import (rootDir + "/nixos/derivations/hardware/video/nvidia/kernel-packages.nix") { inherit config; inherit pkgs; };
  hostname = "monadrecon";
  usernames = [ "simcra" ];
in
{
  imports = [ ../. ];

  # Platform / Generated
  nixpkgs.hostPlatform = "x86_64-linux";
  networking.hostName = hostname;
  users.users = lib.genAttrs usernames (username: import ./users/${username}.nix);
  home-manager.users = lib.genAttrs usernames (username: import (rootDir + "/home-manager/configurations/${hostname}/${username}.nix"));

  # Boot configuration
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.unstable.linuxPackages_latest;
    kernelModules = [ "kvm-intel" ];
    initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
    #extraModulePackages = with config.boot.kernelPackages; [ lenovo-legion-module ];
  };

  # Filesystems
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/b383744e-e411-4938-945b-ba68efe327ec";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/6985-3D9F";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };
  };
  swapDevices = [ ];

  # Locale
  time.timeZone = "Australia/Adelaide";
  i18n = rec {
    defaultLocale = "en_AU.UTF-8";
    extraLocaleSettings = {
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
  services.xserver.xkb = {
    layout = "au";
    variant = "";
  };

  # Hardware
  hardware = {
    cpu.intel.updateMicrocode = config.hardware.enableRedistributableFirmware;
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    nvidia = {
      modesetting.enable = true;
      powerManagement = {
        enable = true;
        finegrained = false; # Finegrained power management causes issues, even on laptops
      };
      open = false;
      nvidiaSettings = true;
      package = nvidiaPackages.stable;
      prime = {
        intelBusId = "PCI:00:02:0";
        nvidiaBusId = "PCI:01:00:0";
        reverseSync.enable = true; # Experimental
        offload = {
          # Use NVIDIA Optimus Prime Offload to reduce power consumption when GPU not in use
          enable = true;
          enableOffloadCmd = true;
        };
        sync.enable = false;
      };
    };
    intelgpu = {
      enable = true;
      driver = "xe";
    };
  };
  services.xserver.videoDrivers = [ "modesetting" "nvidia" ];
  services.thermald.enable = true; # Enable cooling management

  # Network
  networking = {
    firewall = {
      # Spotify
      allowedTCPPorts = [ 57621 ];
      allowedUDPPorts = [ 5353 ];
    };
  };

  # Programs
  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = false;
      localNetworkGameTransfers.openFirewall = true;
      gamescopeSession.enable = true;
    };
    gamemode = {
      enable = true;
      enableRenice = true;
    };
  };

  # Environment
  environment = {
    variables.VDPAU_DRIVER = "va_gl";
    sessionVariables.LIBVA_DRIVER_NAME = "iHD";
    systemPackages = with pkgs; [
      mangohud # FPS counter and performance overlay
    ];
  };

  # Specialisations
  specialisation = {
    desktop.configuration = {
      system.nixos.tags = [ "desktop" ];
      services.xserver.videoDrivers = lib.mkForce [ "nvidia" ];
      hardware.nvidia = {
        powerManagement.enable = lib.mkForce false;
        prime.offload = {
          enable = lib.mkForce false;
          enableOffloadCmd = lib.mkForce false;
        };
      };
      environment = {
        variables.VDPAU_DRIVER = lib.mkForce "nvidia";
        sessionVariables.LIBVA_DRIVER_NAME = lib.mkForce "nvidia";
      };
    };
  };
}
