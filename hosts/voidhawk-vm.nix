{ lib, ... }: {
  # Bootloader
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;
  boot.initrd.availableKernelModules = [ "ata_piix" "ohci_pci" "ehci_pci" "ahci" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  # Filesystem
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/d3cc35c9-0acd-4436-ba4d-e221f3994eab";
    fsType = "ext4";
  };
  swapDevices = [ ];

  # Platform
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # Networking
  networking = {
    hostName = "voidhawk-vm";
    networkmanager.enable = true;
    useDHCP = lib.mkDefault true;
    wireguard.interfaces.asluni.ips = [ "172.16.2.12/32" ];
    hosts =
      let
        cypress = [
          "cypress.local"
          "sesh.cypress.local"
          "tape.cypress.local"
          "codex.cypress.local"
          "chat.cypress.local"
        ];
      in
      {
        "172.16.2.1" = cypress;
      };
  };

  # X11 / Desktop Environment
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  # Printing
  services.printing.enable = true;

  # Sound
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
  };

  # VirtualBox
  virtualisation.virtualbox.guest.enable = true;
}
