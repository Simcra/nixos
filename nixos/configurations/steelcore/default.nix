{
  config,
  lib,
  pkgs,
  ...
}:
let
  rootDir = ../../..;
  nvidiaPackages = import (rootDir + "/nixos/derivations/hardware/video/nvidia/kernel-packages.nix") {
    inherit config;
    inherit pkgs;
  };
  hostname = "steelcore";
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
      "nvme"
      "sd_mod"
      "usbhid"
      "usb_storage"
      "xhci_pci"
    ];
    swraid = {
      enable = true;
      mdadmConf = ''
        ARRAY /dev/md0 UUID=a6eecb29:aeb84d8e:cd7efbdc:d6790fe4
        ARRAY /dev/md1 UUID=2baff7ac:bf892da4:64f454c7:799039c7
      '';
    };
  };

  # Filesystems
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/f3ebccfa-9f4c-43f1-a7f3-5842bd274d78";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/C19D-F445";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };
    "/home" = {
      device = "/dev/disk/by-uuid/a04e3a5f-b705-4fac-a70e-1c032d452dc6";
      fsType = "ext4";
    };
    "/mnt/storage" = {
      device = "/dev/disk/by-uuid/8a2415b9-670a-4df2-b6bc-8d0009e802a7";
      fsType = "ext4";
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
      nvidiaPersistenced = false;
      package = nvidiaPackages.latest;
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
      dedicatedServer.openFirewall = true;
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
    ];
  };
}
