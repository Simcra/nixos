{ outputs, config, lib, pkgs, ... }:
{
  # Import relevant nixosModules for this system
  imports = [
    ../.
    outputs.nixosModules.gaming.steam
    outputs.nixosModules.hardware.nvidia-gpu.mobile
    outputs.nixosModules.hardware.intel-gpu
    outputs.nixosModules.i18n.en-AU.adelaide
    # outputs.nixosModules.network.asluni.monadrecon
    outputs.nixosModules.network.spotify
  ];

  # Boot configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ lenovo-legion-module ];

  # Platform
  nixpkgs.hostPlatform = "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = config.hardware.enableRedistributableFirmware;
  hardware.intelgpu.driver = "xe";
  services.hdapsd.enable = true; # Enable Hard Drive Active Protection System Daemon
  services.thermald.enable = true; # Enable cooling management
  services.xserver.dpi = 189; # √(2560² + 1600²) px / 16 in ≃ 189 dpi
  services.xserver.videoDrivers = [ "modesetting" "nvidia" ]; # Need to enable both modesetting and nvidia

  # NVIDIA Prime
  hardware.nvidia.prime = {
    # Bus IDs
    intelBusId = "PCI:00:02:0";
    nvidiaBusId = "PCI:01:00:0";

    # Using NVIDIA Prime Reverse Sync
    reverseSync.enable = lib.mkOverride 990 true;

    # Using NVIDIA Prime Offload to enable power management
    offload = {
      enable = lib.mkOverride 990 true;
      enableOffloadCmd = lib.mkIf config.hardware.nvidia.prime.offload.enable true;
    };
  };

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

  # Networking
  networking.hostName = "monadrecon";

  # Users
  users.users.simcra = outputs.users.simcra;
}
