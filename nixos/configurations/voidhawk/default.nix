{ config, lib, pkgs, azLib, azFlakeModules, ... }:
let
  rootDir = ../../..;
  nvidiaPackages = import (rootDir + "/nixos/derivations/hardware/video/nvidia/kernel-packages.nix") { inherit config; };
  hostname = "voidhawk";
  usernames = [ "simcra" ];
in
{
  imports = [ ../. ];

  # Boot configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.availableKernelModules = [ "vmd" "xhci_pci" "megaraid_sas" "ahci" "thunderbolt" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ "kvm-intel" ];

  # Platform
  nixpkgs.hostPlatform = "x86_64-linux";
  networking.hostName = hostname;
  hardware.cpu.intel.updateMicrocode = config.hardware.enableRedistributableFirmware;

  # Filesystem
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/a213722d-c87e-43a9-8b6b-9b5e2883c1bf";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/06B3-AC51";
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
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement = {
      enable = false;
      finegrained = false;
    };
    open = false;
    nvidiaSettings = true;
    package = nvidiaPackages.stable;
  };
  environment.variables.VDPAU_DRIVER = "nvidia";
  environment.sessionVariables.LIBVA_DRIVER_NAME = "nvidia";

  # Firewall
  networking.firewall = {
    # Spotify
    allowedTCPPorts = [ 57621 ];
    allowedUDPPorts = [ 5353 ];
  } // {
    # Satisfactory
    allowedTCPPorts = [ 5222 6666 ];
    allowedUDPPorts = [ 5222 6666 ];
    allowedUDPPortRanges = [{ from = 7777; to = 7827; }];
  };

  # Wireguard
  networking.wireguard.interfaces = {
    asluni = {
      privateKeyFile = "/var/lib/wireguard/asluni";
      generatePrivateKeyFile = true;
      peers = azLib.toNonFlakeParts azFlakeModules.asluni.wireguard.networks.asluni.peers.by-name;
      ips = [ "172.16.2.12/32" ];
    };
  };
  networking.hosts =
    let
      cypress = [
        "cypress.local"
        "sesh.cypress.local"
        "tape.cypress.local"
        "codex.cypress.local"
        "chat.cypress.local"
      ];
    in
    {
      "172.16.2.1" = cypress;
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
    megacli # Voidhawk has a MegaRAID SAS card
    ntfs3g # Voidhawk has ntfs volumes connected
    quickemu # Wrapper for QEMU that provides quick VMs

    # All of this is for WINE
    cabextract
    p7zip
    wineWowPackages.stagingFull
    winetricks
  ];
}
