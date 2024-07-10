{ config, lib, pkgs, ... }:
let
  inherit (lib)
    mkOption
    mkEnableOption
    mkDefault
    mkIf
    types
    versionAtLeast;
  cfg = config.std.drivers.intelgpu;
  cfgInitrd = config.boot.initrd;
  cfgX11 = config.services.xserver;
  kernelVersion = config.boot.kernelPackages.kernel.version;
in
{
  options.std.drivers.intelgpu = {
    enable = mkEnableOption {
      default = false;
      description = "Enable the Intel GPU driver";
    };

    enableInitrd = mkEnableOption {
      default = cfg.enable && cfgInitrd.enable;
      description = "Enable the Intel GPU driver at stage 1 boot";
    };

    enableX11 = mkEnableOption {
      default = cfg.enable && cfgX11.enable;
      description = "Enable NVIDIA GPU driver support in X11";
    };

    kernelModule = mkOption {
      type = types.enum [ "i915" "xe" ];
      default = "i915";
      description = ''
        The kernel module to be loaded for the Intel GPU.
        Note that 'xe' is only supported on linux kernel 6.8+.
      '';
    };
  };

  config = mkIf cfg.enable {
    # Install the initrd kernel module
    boot.initrd.kernelModules = mkIf (cfgInitrd.enable && cfg.enableInitrd) [ cfg.kernelModule ];

    # Enable Graphics/OpenGL support
    hardware.opengl = {
      enable = mkDefault true;
      driSupport = mkDefault true;
      # driSupport32 = mkDefault true;
      extraPackages = [
        (if pkgs ? intel-vaapi-driver
        then pkgs.intel-vaapi-driver
        else pkgs.vaapiIntel)
        pkgs.intel-media-driver
      ];
      extraPackages32 = [
        (if pkgs.driversi686Linux ? intel-vaapi-driver
        then pkgs.driversi686Linux.intel-vaapi-driver
        else pkgs.driversi686Linux.vaapiIntel)
        pkgs.intel-media-driver
      ];
    };

    # Set the VDPAU_DRIVER environment variable
    environment.variables = {
      VDPAU_DRIVER = mkDefault "va_gl";
    };

    # Enable modesetting driver for X11
    services.xserver.videoDrivers = mkIf (cfgX11.enable && cfg.enableX11) [ "modesetting" ];

    # Assert that kernel module is valid
    assertions = [{
      assertion = (cfg.kernelModule != "xe" || versionAtLeast kernelVersion "6.8");
      message = "Intel Xe GPU driver is not supported on kernels earlier than 6.8.";
    }];
  };
}
