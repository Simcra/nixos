{ defaults, modules, users, ... }:
{
  # Import relevant nixosModules for this system
  imports = [
    defaults.nixos
    modules.nixos.i18n.en-AU.adelaide
    modules.nixos.network.asluni
  ];

  # Boot configuration
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;
  boot.initrd.availableKernelModules = [ "ata_piix" "ohci_pci" "ehci_pci" "ahci" "sd_mod" "sr_mod" ];

  # Platform
  nixpkgs.hostPlatform = "x86_64-linux";

  # Filesystem
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/d3cc35c9-0acd-4436-ba4d-e221f3994eab";
    fsType = "ext4";
  };
  swapDevices = [ ];

  # Networking
  networking.hostName = "voidhawk-vm";
  networking.wireguard.interfaces.asluni.ips = [ "172.16.2.12/32" ]; # Shared with voidhawk, they cannot be online at the same time

  # Users
  users.users.simcra = users.simcra;

  # VirtualBox
  virtualisation.virtualbox.guest.enable = true;
}
