{ config, pkgs, ... }:
{
  imports = [
    ./users
  ];

  # Boot configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.availableKernelModules = [ "vmd" "xhci_pci" "megaraid_sas" "ahci" "thunderbolt" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ "kvm-intel" ];

  # Platform
  nixpkgs.hostPlatform = "x86_64-linux";
  networking.hostName = "voidhawk";
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

  # SENix configuration
  senix.drivers.nvidia.enable = true;
  senix.firewall.allowSpotify = true;
  senix.networks.asluni = {
    enable = true;
    ipAddresses = [ "172.16.2.12/32" ];
  };
  senix.software.steam.enable = true;

  # System packages
  environment.systemPackages = with pkgs; [
    bottles # WINE prefix manager for everything that won't run natively or under steam
    megacli # Voidhawk has a MegaRAID SAS card
    ntfs3g # Voidhawk has ntfs volumes connected
  ];
}
