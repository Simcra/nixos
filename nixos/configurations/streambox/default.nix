{
  config,
  lib,
  pkgs,
  ...
}:
let
  rootDir = ../../..;
  hostname = "streambox";
  usernames = [
    "darkcrystal"
    "simcra"
  ];
in
{
  imports = [ ../. ];

  # Platform / Generated
  nixpkgs.hostPlatform = "x86_64-linux";
  networking.hostName = hostname;
  users.users = lib.genAttrs usernames (username: import ./users/${username}.nix);
  home-manager.users = lib.genAttrs usernames (
    username: import (rootDir + "/home-manager/configurations/${hostname}/${username}.nix")
  );

  # Boot configuration
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [ "kvm-intel" ];
    initrd.availableKernelModules = [
      "ahci"
      "xhci_pci"
      "dwc3_pci"
      "usbhid"
      "usb_storage"
      "sd_mod"
      "sdhci_pci"
    ];
    extraModprobeConfig = ''
      options snd-intel-dspcfg dsp_driver=1
    '';
  };

  # Filesystems
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/0ee89acb-0ee5-40c7-9d1c-bda414aa418e";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/DDF9-4A83";
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
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
    intelgpu = {
      enable = true;
      driver = "xe";
    };
  };
  services.xserver.videoDrivers = [ "modesetting" ];

  # Network
  networking = {
    firewall = {
      # Spotify
      allowedTCPPorts = [ 57621 ];
      allowedUDPPorts = [ 5353 ];
    };
  };

  # Environment
  environment = {
    variables.VDPAU_DRIVER = "va_gl";
    sessionVariables.LIBVA_DRIVER_NAME = "i965";
  };
}
