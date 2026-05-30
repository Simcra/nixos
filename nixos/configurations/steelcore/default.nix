{
  config,
  lib,
  pkgs,
  ...
}:
let
  rootDir = ../../..;
  hostname = "steelcore";
  users = [
    "darkcrystal"
    "simcra"
  ];
  groups = [ "archive" ];
in
{
  imports = [
    ../.
    ../avahi.nix
    ../grd.nix
    ../spotify.nix
    ./llm.nix
    ./smb.nix
  ];

  # Platform / Generated
  nixpkgs.hostPlatform = "x86_64-linux";
  networking.hostName = hostname;
  users.users = lib.genAttrs users (user: import ./users/${user}.nix);
  users.groups = lib.genAttrs groups (group: { });
  home-manager.users = lib.genAttrs users (
    user: import (rootDir + "/home-manager/configurations/${hostname}/${user}.nix")
  );
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  # Boot configuration
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelModules = [
      "ahci"
      "kvm-intel"
    ];
    kernelPackages = pkgs.linuxPackages_latest;
    initrd.availableKernelModules = [
      "ahci"
      "megaraid_sas"
      "nvme"
      "sd_mod"
      "thunderbolt"
      "usbhid"
      "usb_storage"
      "xhci_pci"
    ];
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
    "/media/archive" = {
      device = "/dev/disk/by-uuid/F6E4B290E4B2531B";
      fsType = "ntfs3";
      options = [
        "uid=1000"
        "gid=1000"
        "umask=077"
        "nofail"
      ];
    };
    "/media/storage" = {
      device = "/dev/disk/by-uuid/9CB8A9A2B8A97B80";
      fsType = "ntfs3";
      options = [
        "uid=1000"
        "gid=1000"
        "umask=007"
        "nofail"
      ];
    };
  };
  swapDevices = [ ];
  systemd.tmpfiles.rules = [
    "Z /media/archive 2770 simcra archive -"
    "Z /media/storage 2770 simcra users -"
  ];

  # Hardware
  hardware = {
    cpu.intel.updateMicrocode = config.hardware.enableRedistributableFirmware;

    graphics = {
      enable = true;
      enable32Bit = true;
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

  # Services
  services.satisfactory-dedicated-server = {
    enable = true;
    openFirewall = true;
    serviceExtraGroups = [ "archive" ];
    backups = {
      enable = true;
      dir = "/media/archive/Backups/${lib.toUpper hostname}";
      period = "daily";
      retention = 14;
    };
  };

  # Environment
  environment = {
    systemPackages = with pkgs; [
      mangohud # FPS counter and performance overlay
      megacli
      ntfs3g
      radeontop
      vesktop
    ];
  };
}
