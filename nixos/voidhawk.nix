{ outputs, lib, config, ... }:
{
  # Import relevant nixosModules for this system
  imports = [
    ./common.nix
    outputs.nixosModules.hardware.megaraid-sas
    outputs.nixosModules.hardware.nvidia-desktop-stable
    outputs.nixosModules.i18n.en-AU-ADL
    outputs.nixosModules.network.asluni.voidhawk
    outputs.nixosModules.programs.direnv
    outputs.nixosModules.programs.spotify
    outputs.nixosModules.programs.steam
    outputs.nixosModules.services.openssh
  ];

  # Boot configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.availableKernelModules = [ "vmd" "xhci_pci" "megaraid_sas" "ahci" "thunderbolt" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # Platform
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

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
  networking.networkmanager.enable = true;
  networking.useDHCP = lib.mkDefault true;
  networking.hostName = "voidhawk";

  # Users
  users.users.simcra = outputs.users.simcra;

}
