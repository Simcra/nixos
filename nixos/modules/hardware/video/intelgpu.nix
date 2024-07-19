{ config, lib, pkgs, ... }:
let
  inherit (lib)
    mkOption
    mkDefault
    mkIf
    types
    versionAtLeast;
  cfg = config.hardware.intelgpu;
  cfgGraphics = config.hardware.graphics;
  cfgKernel = config.boot.kernelPackages.kernel;
in
{
  imports = [ ./. ];

  options = {
    hardware.intelgpu = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Enable driver support for Intel GPUs. This option should enable
          support for both Intel iGPU and dGPU variants.
        '';
      };

      driver = mkOption {
        type = types.enum [ "i915" "xe" ];
        default = if versionAtLeast cfgKernel.version "6.8" then "xe" else "i915";
        description = ''
          Driver to be loaded for the Intel GPU, defaults to "xe" on newer
          kernels, and "i915" on older kernels. The "xe" driver provides
          significantly better performance so it is advised to use this one
          wherever possible.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    boot.initrd.kernelModules = [ cfg.driver ];

    hardware.graphics = mkIf cfgGraphics.enable {
      extraPackages =
        if pkgs ? intel-vaapi-driver
        then with pkgs; [ intel-vaapi-driver intel-media-driver ]
        else with pkgs; [ vaapiIntel intel-media-driver ];
      extraPackages32 =
        if pkgs.driversi686Linux ? intel-vaapi-driver
        then with pkgs.driversi686Linux; [ intel-vaapi-driver intel-media-driver ]
        else with pkgs.driversi686Linux; [ vaapiIntel intel-media-driver ];
    };

    environment.variables = {
      VDPAU_DRIVER = mkIf cfgGraphics.enable (mkDefault "va_gl");
    };

    services.xserver.videoDrivers = [ "modesetting" ];

    assertions = [{
      assertion = (cfg.driver != "xe" || versionAtLeast cfgKernel.version "6.8");
      message = ''
        Intel Xe GPU driver is not supported on kernels earlier than 6.8.
        Update your kernel or use the i915 driver.
      '';
    }];
  };
}
