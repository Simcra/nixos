{ config, pkgs, defaults, modules, users, ... }:
{
  # Import relevant modules for this system
  imports = [
    defaults.nixos
    modules.nixos.hardware.intelgpu
    modules.nixos.i18n.en-AU.adelaide
    modules.nixos.network.spotify
  ];

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
  hardware.cpu.intel.updateMicrocode = config.hardware.enableRedistributableFirmware;
  hardware.intelgpu.driver = "xe";

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

  # Networking
  networking.hostName = "streambox";

  # Users
  users.users.simcra = users.simcra;
  users.users.darkcrystal = users.darkcrystal;
}
