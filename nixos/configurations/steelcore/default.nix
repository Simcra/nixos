{
  config,
  lib,
  pkgs,
  ...
}:
let
  rootDir = ../../..;
  hostname = "steelcore";
  usernames = [
    "darkcrystal"
    "simcra"
  ];
in
{
  imports = [
    ../.
    ../grd.nix
    ../spotify.nix
  ];

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
    kernelModules = [
      "ahci"
      "kvm-intel"
      "md_mod"
      "raid1"
    ];
    kernelPackages = pkgs.linuxPackages_latest;
    initrd.availableKernelModules = [
      "ahci"
      "md_mod"
      "nvme"
      "raid1"
      "sd_mod"
      "usbhid"
      "usb_storage"
      "xhci_pci"
    ];
    swraid = {
      enable = true;
      mdadmConf = ''
        MAILADDR 5228381+Simcra@users.noreply.github.com
        ARRAY /dev/md0 metadata=1.2 UUID=348ace44:75728a1b:556800c2:4d3f70a3
        ARRAY /dev/md1 metadata=1.2 UUID=1f63e693:cea88d1a:27675066:2adade91
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
    "/mnt/scratch" = {
      device = "/dev/md0";
      fsType = "ext4";
      options = [ "nofail" ];
    };
    "/mnt/storage" = {
      device = "/dev/md1";
      fsType = "ext4";
      options = [ "nofail" ];
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
    systemPackages = with pkgs; [
      mangohud # FPS counter and performance overlay
      vesktop
    ];
  };
}
