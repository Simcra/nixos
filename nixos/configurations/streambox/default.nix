{ config, lib, pkgs, ... }:
let
  hostname = "streambox";
  usernames = [ "darkcrystal" "simcra" ];
in
{
  imports = [ ../. ];

  # Boot configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "dwc3_pci" "usbhid" "usb_storage" "sd_mod" "sdhci_pci" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.extraModprobeConfig = ''
    options snd-intel-dspcfg dsp_driver=1
  '';

  # Platform
  nixpkgs.hostPlatform = "x86_64-linux";
  networking.hostName = hostname;
  hardware.cpu.intel.updateMicrocode = config.hardware.enableRedistributableFirmware;

  # Filesystem
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/0ee89acb-0ee5-40c7-9d1c-bda414aa418e";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/DDF9-4A83";
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
  services.xserver.videoDrivers = [ "modesetting" ];
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  hardware.intelgpu = {
    enable = true;
    driver = "xe";
  };
  environment.variables.VDPAU_DRIVER = "va_gl";
  environment.sessionVariables.LIBVA_DRIVER_NAME = "i965";

  # Firewall
  networking.firewall = {
    # Spotify local discovery
    allowedTCPPorts = [ 57621 ];
    allowedUDPPorts = [ 5353 ];
  };
}
