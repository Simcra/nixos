{ outputs, lib, ... }:
{
  # Import relevant nixosModules for this system
  imports = [
    ./common.nix
    outputs.nixosModules.i18n.en-AU-ADL
    outputs.nixosModules.network.asluni.voidhawk-vm
    outputs.nixosModules.programs.direnv
    outputs.nixosModules.programs.spotify
    outputs.nixosModules.programs.steam
    outputs.nixosModules.services.openssh
  ];

  # Boot configuration
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;
  boot.initrd.availableKernelModules = [ "ata_piix" "ohci_pci" "ehci_pci" "ahci" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  # Platform
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # Filesystem
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/d3cc35c9-0acd-4436-ba4d-e221f3994eab";
    fsType = "ext4";
  };
  swapDevices = [ ];

  # Networking
  networking.networkmanager.enable = true;
  networking.useDHCP = lib.mkDefault true;
  networking.hostName = "voidhawk-vm";

  # Users
  users.users.simcra = outputs.nixosUsers.simcra;

  # VirtualBox
  virtualisation.virtualbox.guest.enable = true;
}