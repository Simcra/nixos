{ config, lib, pkgs, ... }:
let
  rootDir = ../../..;
  nvidiaPackages = import (rootDir + "/nixos/derivations/hardware/video/nvidia/kernel-packages.nix") { inherit config; };
  hostname = "voidhawk";
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
    kernelPackages = pkgs.unstable.linuxPackages;
    kernelModules = [ "kvm-intel" ];
    initrd.availableKernelModules = [ "vmd" "xhci_pci" "megaraid_sas" "ahci" "thunderbolt" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  };

  # Filesystems
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/a213722d-c87e-43a9-8b6b-9b5e2883c1bf";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/06B3-AC51";
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
        enable = false;
        finegrained = false;
      };
      open = false;
      nvidiaSettings = true;
      package = nvidiaPackages.stable;
    };
  };
  services.xserver.videoDrivers = [ "nvidia" ];

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
    variables.VDPAU_DRIVER = "nvidia";
    sessionVariables.LIBVA_DRIVER_NAME = "nvidia";
    systemPackages = with pkgs; [
      mangohud # FPS counter and performance overlay
      megacli # Voidhawk has a MegaRAID SAS card
      ntfs3g # Voidhawk has ntfs volumes connected
    ];
  };
}
