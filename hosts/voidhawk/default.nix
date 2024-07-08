{ outputs, config, pkgs, ... }:
{
  # Import relevant nixosModules for this system
  imports = [
    ../.
    outputs.nixosModules.gaming.steam
    outputs.nixosModules.hardware.nvidia-gpu.desktop
    outputs.nixosModules.hardware.intel-gpu
    outputs.nixosModules.i18n.en-AU.adelaide
    # voidhawk and voidhawk-vm share the same wireguard configuration since they'll never both be online at the same time
    outputs.nixosModules.network.asluni.voidhawk
    outputs.nixosModules.network.spotify
  ];

  # Boot configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.availableKernelModules = [ "vmd" "xhci_pci" "megaraid_sas" "ahci" "thunderbolt" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ "kvm-intel" ];

  # Platform
  nixpkgs.hostPlatform = "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = config.hardware.enableRedistributableFirmware;
  hardware.intelgpu.driver = "xe";

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
    bottles # WINE prefix manager for everything that won't run natively or under steam
    megacli # Voidhawk has a MegaRAID SAS card
    ntfs3g # Voidhawk has ntfs volumes connected
  ];
}
