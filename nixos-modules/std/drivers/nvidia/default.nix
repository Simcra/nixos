{ config, lib, pkgs, ... }:
let
  inherit (lib)
    mkOption
    mkEnableOption
    mkDefault
    mkIf
    types;
  cfg = config.std.drivers.nvidia;
  cfgInitrd = config.boot.initrd;
  cfgX11 = config.services.xserver;
  pkgsKernel = config.boot.kernelPackages;
  pkgsNvidia = pkgsKernel.nvidiaPackages;
in
{
  options.std.drivers.nvidia = {
    enable = mkEnableOption {
      default = false;
      description = "Enable the NVIDIA GPU driver";
    };

    enableInitrd = mkEnableOption {
      default = cfg.enable && cfgInitrd.enable;
      description = "Enable the NVIDIA GPU driver at stage 1 boot";
    };

    enablePrimeOffload = mkEnableOption {
      default = cfg.enable && cfg.enableX11 && cfg.platform == "mobile";
      description = ''
        Enable NVIDIA Optimus Prime Offload capabilities.
        Defaults to enabled if this driver is being enabled on a 'mobile' system.
        This should manually be set to false if your system does not have an iGPU.
      '';
    };

    enablePrimeRSync = mkEnableOption {
      default = cfg.enable && cfg.enableX11 && cfg.platform == "mobile";
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
      default = cfg.enable && cfgX11.enable;
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
        pkgsNvidia.latest
        pkgsNvidia.beta
        pkgsNvidia.production
        pkgsNvidia.stable
        pkgsNvidia.legacy_470
        pkgsNvidia.legacy_390
        pkgsNvidia.legacy_340
        pkgsNvidia.vulkan_beta
      ];
      default = pkgsNvidia.stable;
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

  config = mkIf cfg.enable (
    let
      x11Package = {
        pkgsNvidia.latest = pkgsKernel.nvidia_x11;
        pkgsNvidia.beta = pkgsKernel.nvidia_x11_beta;
        pkgsNvidia.production = pkgsKernel.nvidia_x11_production;
        pkgsNvidia.stable = pkgsKernel.nvidia_x11;
        pkgsNvidia.legacy_470 = pkgsKernel.nvidia_x11_legacy470;
        pkgsNvidia.legacy_390 = pkgsKernel.nvidia_x11_legacy390;
        pkgsNvidia.legacy_340 = pkgsKernel.nvidia_x11_legacy340;
        pkgsNvidia.vulkan_beta = pkgsKernel.nvidia_x11_vulka_beta;
      };
    in
    {
      # Install the initrd kernel module
      boot.initrd.kernelModules = mkIf (cfgInitrd.enable && cfg.enableInitrd) [ cfg.kernelModule ];

      # Configure NVIDIA hardware
      hardware.nvidia = {
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
        package = mkDefault cfg.kernelPackage;
      };

      # Enable Graphics/OpenGL support
      hardware.opengl = {
        enable = mkDefault true;
        driSupport = mkDefault true;
        # driSupport32 = mkDefault true;
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
      boot.extraModulePackages = mkIf (cfgX11.enable && cfg.enableX11) [ x11Package ];
      services.xserver.videoDrivers = mkIf (cfgX11.enable && cfg.enableX11) [ "nvidia" ];
    }
  );
}
