{ config, pkgs, ... }:
{
  imports = [
    # For now we just copy users from voidhawk
    ../voidhawk/users
  ];

  # Boot configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.extraModulePackages = with config.boot.kernelPackages; [ lenovo-legion-module ];

  # Platform
  nixpkgs.hostPlatform = "x86_64-linux";
  networking.hostName = "monadrecon";
  hardware.cpu.intel.updateMicrocode = config.hardware.enableRedistributableFirmware;
  hardware.nvidia.prime.intelBusId = "PCI:00:02:0";
  hardware.nvidia.prime.nvidiaBusId = "PCI:01:00:0";
  services.hdapsd.enable = true; # Enable Hard Drive Active Protection System Daemon
  services.thermald.enable = true; # Enable cooling management
  services.xserver.dpi = 189; # √(2560² + 1600²) px / 16 in ≃ 189 dpi
  #services.xserver.videoDrivers = [ "modesetting" "nvidia" ]; # Need to enable both modesetting and nvidia

  # Filesystem
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/b383744e-e411-4938-945b-ba68efe327ec";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/6985-3D9F";
    fsType = "vfat";
    options = [ "fmask=0022" "dmask=0022" ];
  };
  swapDevices = [ ];

  # SENix configuration
  senix.drivers.intelgpu.enable = true;
  senix.drivers.nvidia.enable = true;
  senix.drivers.nvidia.enablePrimeOffload = true;
  senix.drivers.nvidia.enablePrimeRSync = true;
  senix.drivers.nvidia.platform = "mobile";
  senix.firewall.allowSpotify = true;
  # TODO
  # senix.networks.asluni = {
  # enable = true;
  # ipAddresses = [ "172.16.2.12/32" ];
  # };
  senix.software.steam.enable = true;
}
