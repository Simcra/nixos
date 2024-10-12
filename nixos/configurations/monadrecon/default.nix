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
    package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
      version = "550.120";
      sha256_64bit = "sha256-gBkoJ0dTzM52JwmOoHjMNwcN2uBN46oIRZHAX8cDVpc=";
      sha256_aarch64 = "sha256-dzTEUuSIWKEuAMhsL9QkR7CCHpm6m9ZwtGSpSKqwJdc=";
      openSha256 = "sha256-O3OrGGDR+xrpfyPVQ04aM3eGI6aWuZfRzmaPjMfnGIg=";
      settingsSha256 = "sha256-fPfIPwpIijoUpNlAUt9C8EeXR5In633qnlelL+btGbU=";
      persistencedSha256 = "sha256-ztEemWt0VR+cQbxDmMnAbEVfThdvASHni4SJ0dTZ2T4=";
    };
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
}
