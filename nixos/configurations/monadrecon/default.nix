{ config, lib, pkgs, ... }:
let
  rootDir = ../../..;
  nvidiaPackages = import (rootDir + "/nixos/derivations/hardware/video/nvidia/kernel-packages.nix") { inherit config; };
  hostname = "monadrecon";
  usernames = [ "simcra" ];
in
{
  imports = [ ../. ];

  # Boot configuration
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ "kvm-intel" ];
  # boot.extraModulePackages = with config.boot.kernelPackages; [ lenovo-legion-module ];

  # Platform
  nixpkgs.hostPlatform = "x86_64-linux";
  networking.hostName = hostname;
  hardware.cpu.intel.updateMicrocode = config.hardware.enableRedistributableFirmware;
  services.hdapsd.enable = true; # Enable Hard Drive Active Protection System Daemon
  services.thermald.enable = true; # Enable cooling management

  # Filesystem
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/b383744e-e411-4938-945b-ba68efe327ec";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/6985-3D9F";
    fsType = "vfat";
    options = [ "fmask=0022" "dmask=0022" ];
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

  # Users
  users.users = lib.genAttrs usernames (username: import ./users/${username}.nix);

  # Home Manager
  home-manager.users = lib.genAttrs usernames (username: import ../../../home-manager/configurations/${hostname}/${username}.nix);

  # Graphics
  services.xserver.videoDrivers = [ "modesetting" "nvidia" ];
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement = {
      enable = true;
      finegrained = false; # Finegrained power management causes issues, even on laptops
    };
    open = false;
    nvidiaSettings = true;
    package = nvidiaPackages.recommended;
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
  hardware.intelgpu = {
    enable = true;
    driver = "xe";
  };
  environment.variables.VDPAU_DRIVER = "va_gl";
  environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";

  # Firewall
  networking.firewall = {
    # Spotify
    allowedTCPPorts = [ 57621 ];
    allowedUDPPorts = [ 5353 ];
  };

  # Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = false;
    localNetworkGameTransfers.openFirewall = true;
    gamescopeSession.enable = true;
  };
  programs.gamemode = {
    enable = true;
    enableRenice = true;
  };

  # Environment
  environment.systemPackages = with pkgs; [
    mangohud # FPS counter and performance overlay
  ];

  # Specialisations
  specialisation = {
    desktop.configuration = {
      system.nixos.tags = [ "desktop" ];
      services.xserver.videoDrivers = lib.mkForce [ "nvidia" ];
      hardware.nvidia.powerManagement.enable = lib.mkForce false;
      hardware.nvidia.prime.offload.enable = lib.mkForce false;
      hardware.nvidia.prime.offload.enableOffloadCmd = lib.mkForce false;
      environment.variables.VDPAU_DRIVER = lib.mkForce "nvidia";
      environment.sessionVariables.LIBVA_DRIVER_NAME = lib.mkForce "vdpau";
    };
  };
}
