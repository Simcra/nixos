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
  hostname = "voidhawk";
  users = [ "simcra" ];
in
{
  imports = [
    ../.
    ../samba.nix
    ../spotify.nix
  ];

  # Platform / Generated
  nixpkgs.hostPlatform = "x86_64-linux";
  networking.hostName = hostname;
  users.users = lib.genAttrs users (user: import ./users/${user}.nix);
  home-manager.users = lib.genAttrs users (
    user: import (rootDir + "/home-manager/configurations/${hostname}/${user}.nix")
  );

  # Boot configuration
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelModules = [ "kvm-intel" ];
    kernelPackages = pkgs.linuxPackages_latest;
    initrd.availableKernelModules = [
      "vmd"
      "xhci_pci"
      "ahci"
      "thunderbolt"
      "nvme"
      "usbhid"
      "usb_storage"
      "sd_mod"
    ];
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
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };
  };
  swapDevices = [ ];

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
      package = nvidiaPackages.recommended;
    };
  };
  services.xserver.videoDrivers = [ "nvidia" ];

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
      vesktop
    ];
  };
}
