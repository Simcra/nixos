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
        MAILADDR 5228381+Simcra@users.noreply.github.com
        ARRAY /dev/md0 level=raid1 num-devices=2 UUID=cd381234:0b5c79ef:386068c1:5b72646a
        ARRAY /dev/md1 level=raid1 num-devices=2 UUID=19f52f6e:deb82891:71eec4b0:a3e1787d
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
    # "/mnt/md0" = {
    #   device = "/dev/disk/by-uuid/0cc5f1b9-c577-4114-b38b-32d0499c5c99";
    #   fsType = "ext4";
    # };
    # "/mnt/md1" = {
    #   device = "/dev/disk/by-uuid/d38abc65-cebc-478d-9655-9971623934e8";
    #   fsType = "ext4";
    # };
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
