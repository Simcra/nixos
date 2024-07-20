{ config, lib, pkgs, ... }:
let
  hostname = "monadrecon";
  usernames = [ "simcra" ];
in
{
  imports = [ ../. ];

  # Boot configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ lenovo-legion-module ];

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
  services.xserver.dpi = 189; # √(2560² + 1600²) px / 16 in ≃ 189 dpi
  services.xserver.videoDrivers = [ "modesetting" "nvidia" ];
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  hardware.nvidia = {
    modesetting.enable = true; # Modesetting is required for most NVIDIA GPUs
    powerManagement = {
      enable = true; # Enable power management to reduce power consumption when GPU not in use
      finegrained = false; # Finegrained power management causes issues, even on laptops
    };
    open = false; # Don't use the open source drivers because they are really bad
    nvidiaSettings = true; # Install NVIDIA Settings application
    package = config.boot.kernelPackages.nvidiaPackages.latest;
    prime = {
      intelBusId = "PCI:00:02:0";
      nvidiaBusId = "PCI:01:00:0";
      reverseSync.enable = true; # Enable NVIDIA Optimus Prime RSYNC capabilities
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

  # Firewall
  networking.firewall = {
    # Spotify local discovery
    allowedTCPPorts = [ 57621 ];
    allowedUDPPorts = [ 5353 ];
  } // {
    allowedTCPPorts = [ 27040 ]; # Steam local network transfer
    allowedUDPPortRanges = [{ from = 27031; to = 27036; }]; # Steam client discovery
  };

  # Wireguard
  # networking.wireguard.interfaces = {
  #   asluni = {
  #     privateKeyFile = "/var/lib/wireguard/asluni";
  #     generatePrivateKeyFile = true;
  #     peers = azLib.toNonFlakeParts azFlakeModules.asluni.wireguard.networks.asluni.peers.by-name;
  #     ips = [ "172.16.2.x/32" ];
  #   };
  # };

  # Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = false;
    gamescopeSession.enable = true;
  };
  programs.gamemode = {
    enable = true;
    enableRenice = true;
  };

  # Environment
  environment = {
    sessionVariables = {
      LIBVA_DRIVER_NAME = "i915";
    };
    systemPackages = with pkgs; [
      mangohud # FPS counter and performance overlay
    ];
  };
}
