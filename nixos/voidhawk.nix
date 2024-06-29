{ outputs, pkgs, config, ... }:
{
  # Import relevant nixosModules for this system
  imports = [
    ./common.nix
    outputs.nixosModules.hardware.nvidia-desktop-stable
    outputs.nixosModules.i18n.en-AU-ADL
    outputs.nixosModules.network.asluni.voidhawk
    outputs.nixosModules.network.spotify
    outputs.nixosModules.programs.nix-ld
    outputs.nixosModules.programs.steam
  ];

  # Boot configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.availableKernelModules = [ "vmd" "xhci_pci" "megaraid_sas" "ahci" "thunderbolt" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ "nvidia" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];

  # Configure Xserver to use the nvidia video drivers
  services.xserver.videoDrivers = [ "nvidia" ];

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

  # Users
  users.users.simcra = outputs.users.simcra;

  # System packages
  environment.systemPackages = with pkgs; [
    megacli # Voidhawk has a MegaRAID SAS card
  ];
}
