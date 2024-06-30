{ outputs, config, lib, pkgs, ... }:
{
  # Import relevant nixosModules for this system
  imports = [
    ./common.nix
    outputs.nixosModules.hardware.intel-gpu
    outputs.nixosModules.i18n.en-AU-ADL
    outputs.nixosModules.network.spotify
    outputs.nixosModules.programs.nix-ld
  ];

  # Boot configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "dwc3_pci" "usbhid" "usb_storage" "sd_mod" "sdhci_pci" ];
  boot.kernelModules = [ "kvm-intel" ];

  # Platform
  nixpkgs.hostPlatform = "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = config.hardware.enableRedistributableFirmware;
  services.xserver.displayManager.gdm.autoSuspend = false; # *grumble grumble* autosuspend... 

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
  users.users.simcra = outputs.users.simcra;
  #users.users.media = outputs.users.media;
}
