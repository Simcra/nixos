{ config, lib, pkgs, ... }:
let
  inherit (lib)
    mkOption
    mkEnableOption
    mkDefault
    mkForce
    mkIf
    types;
  cfg = config.senix.drivers.nvidia;
  cfgInitrd = config.boot.initrd;
  cfgX11 = config.services.xserver;
  pkgsNvidia = config.boot.kernelPackages.nvidiaPackages;
in
{
  options.senix.drivers.nvidia = {
    enable = mkEnableOption {
      default = false;
      description = "Enable the NVIDIA GPU driver";
    };

    enableInitrd = mkEnableOption {
      default = true;
      description = "Enable the NVIDIA GPU driver at stage 1 boot";
    };

    enablePrimeOffload = mkEnableOption {
      default = false;
      description = ''
        Enable NVIDIA Optimus Prime Offload capabilities.
        Defaults to enabled if this driver is being enabled on a 'mobile' system.
        This should manually be set to false if your system does not have an iGPU.
      '';
    };

    enablePrimeRSync = mkEnableOption {
      default = false;
      description = ''
        Enable NVIDIA Optimus Prime RSync capabilities.
        Defaults to enabled if this driver is being enabled on a 'mobile' system.
      '';
    };

    enablePrimeSync = mkEnableOption {
      default = false;
      description = ''
        Enable NVIDIA Optimus Prime Sync capabilities.
        Defaults to disabled and cannot be enabled if Prime Offload is being used.
      '';
    };

    enableX11 = mkEnableOption {
      default = true;
      description = "Enable NVIDIA GPU driver support in X11";
    };

    kernelModule = mkOption {
      type = types.enum [ "nvidia" ];
      default = "nvidia";
      description = ''
        The kernel module to be loaded for the NVIDIA GPU.
        Currently only the 'nvidia' kernel module is supported.
        In future 'nouveau' may also be supported.
      '';
    };

    kernelPackage = mkOption {
      type = types.enum [
        "latest"
        "beta"
        "production"
        "stable"
        "legacy_470"
        "vulkan_beta"
      ];
      default = "stable";
      description = "The kernel package to be used for the NVIDIA GPU.";
    };

    platform = mkOption {
      type = types.enum [ "desktop" "mobile" ];
      default = "desktop";
      description = ''
        The platform the driver is being used on, one of 'desktop' or 'mobile'.
        Used to enable/disable features specific to only mobile versions of NVIDIA GPUs.
      '';
    };
  };

  config = {
    # Configure defaults
    senix.drivers.nvidia = {
      enable = mkDefault false;
      enableInitrd = mkDefault (cfgX11.enable && cfg.enableX11);
      enablePrimeOffload = mkDefault (cfgX11.enable && cfg.enableX11 && cfg.platform == "mobile");
      enablePrimeRSync = mkDefault (cfgX11.enable && cfg.enableX11 && cfg.platform == "mobile");
      enablePrimeSync = mkDefault false;
      enableX11 = mkDefault cfgX11.enable;
      kernelModule = mkDefault "nvidia";
      kernelPackage = mkDefault "stable";
      platform = mkDefault "desktop";
    };

    # Need to accept the NVIDIA license to install kernel modules
    nixpkgs.config.nvidia.acceptLicense = cfg.enable;

    # Install the initrd kernel module
    boot.initrd.kernelModules = mkIf (cfg.enable && cfg.enableInitrd && cfgInitrd.enable) [ cfg.kernelModule ];

    # Configure NVIDIA hardware
    hardware.nvidia = mkIf cfg.enable {
      # Modesetting is required for most NVIDIA GPUs
      modesetting.enable = mkDefault true;

      # Power management should only be enabled on mobile platforms
      powerManagement.enable = mkDefault cfg.platform == "mobile";

      # Fine-grained power management is only available on select GPUs
      # Therefore it is infinitely more safe to just disable it
      powerManagement.finegrained = mkDefault false;

      # Don't use the open-source drivers for NVIDIA GPUs because they suck
      open = mkDefault false;

      # Enable the NVIDIA settings application
      nvidiaSettings = mkDefault true;

      # Configure the kernel package
      package = mkDefault config.boot.kernelPackages.nvidiaPackages.${cfg.kernelPackage};

      # Configure NVIDIA Optimus Prime
      prime = {
        reverseSync.enable = mkIf cfg.enablePrimeRSync (mkForce true);
        offload = mkIf cfg.enablePrimeOffload {
          enable = mkForce true;
          enableOffloadCmd = mkDefault true;
        };
        sync.enable = mkIf cfg.enablePrimeSync (mkDefault true);
      };
    };

    # Enable Graphics/OpenGL support
    hardware.opengl = mkIf cfg.enable {
      enable = mkDefault true;
      driSupport = mkDefault true;
      extraPackages = mkIf (cfg.platform == "mobile") [
        (if pkgs ? libva-vdpau-driver
        then pkgs.libva-vdpau-driver
        else pkgs.vaapiVdpau)
      ];
      extraPackages32 = mkIf (cfg.platform == "mobile") [
        (if pkgs.driversi686Linux ? libva-vdpau-driver
        then pkgs.driversi686Linux.libva-vdpau-driver
        else pkgs.driversi686Linux.vaapiVdpau)
      ];
    };

    # Enable NVIDIA GPU support in x11
    boot.extraModulePackages = mkIf (cfg.enable && cfg.enableX11 && cfgX11.enable) (
      let
        modulePackage = {
          "latest" = config.boot.kernelPackages.nvidia_x11;
          "beta" = config.boot.kernelPackages.nvidia_x11_beta;
          "stable" = config.boot.kernelPackages.nvidia_x11;
          "legacy_470" = config.boot.kernelPackages.nvidia_x11_legacy470;
          "vulkan_beta" = config.boot.kernelPackages.nvidia_x11_vulkan_beta;
        }."${cfg.kernelPackage}";
      in
      [ modulePackage ]
    );
    services.xserver.videoDrivers = mkIf (cfg.enable && cfg.enableX11 && cfgX11.enable) [ "nvidia" ];
  };
}
