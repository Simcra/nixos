{ config, pkgs, defaults, modules, users, ... }:
{
  # Import relevant modules for this system
  imports = [
    defaults.nixos
    modules.nixos.hardware.nvidia.desktop
    modules.nixos.i18n.en-AU.adelaide
    modules.nixos.network.asluni
    modules.nixos.network.spotify
    modules.nixos.software.steam
  ];

  # Boot configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.availableKernelModules = [ "vmd" "xhci_pci" "megaraid_sas" "ahci" "thunderbolt" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ "kvm-intel" ];

  # Platform
  nixpkgs.hostPlatform = "x86_64-linux";
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

  # Networking
  networking.hostName = "voidhawk";
  networking.wireguard.interfaces.asluni.ips = [ "172.16.2.12/32" ]; # Shared with voidhawk-vm, they cannot be online at the same time

  # Users
  users.users.simcra = users.simcra;

  # System packages
  environment.systemPackages = with pkgs; [
    bottles # WINE prefix manager for everything that won't run natively or under steam
    megacli # Voidhawk has a MegaRAID SAS card
    ntfs3g # Voidhawk has ntfs volumes connected
  ];
}
