{ config, pkgs, ... }:
{
  imports = [
    ./users
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
  networking.hostName = "streambox";
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

  # SENix configuration
  senix.drivers.intelgpu.enable = true;
  senix.firewall.allowSpotify = true;
}
