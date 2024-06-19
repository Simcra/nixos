{ config, lib, pkgs, ... }: {
  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.availableKernelModules = [ "vmd" "xhci_pci" "megaraid_sas" "ahci" "thunderbolt" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_xanmod_stable; # Performance optimized "gaming" kernel

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

  # Platform
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # NVIDIA
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement = {
      enable = false;
      finegrained = false;
    };
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Networking
  networking = {
    hostName = "voidhawk";
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
    displayManager.gdm = {
      enable = true;
      autoSuspend = false;
    };
    desktopManager.gnome.enable = true;
    videoDrivers = [ "nvidia" ];
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

  # System
  environment.systemPackages = with pkgs; [
    megacli # Voidhawk has a MegaRAID card in it
  ];
}
