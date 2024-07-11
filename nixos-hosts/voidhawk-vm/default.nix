{ ... }:
{
  imports = [
    ./users
  ];

  # Boot configuration
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;
  boot.initrd.availableKernelModules = [ "ata_piix" "ohci_pci" "ehci_pci" "ahci" "sd_mod" "sr_mod" ];

  # Platform
  nixpkgs.hostPlatform = "x86_64-linux";
  networking.hostName = "voidhawk-vm";
  virtualisation.virtualbox.guest.enable = true;

  # Filesystem
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/d3cc35c9-0acd-4436-ba4d-e221f3994eab";
    fsType = "ext4";
  };
  swapDevices = [ ];

  # SENix configuration
  senix.networks.asluni = {
    enable = true;
    ipAddresses = [ "172.16.2.12/32" ];
  };
}
