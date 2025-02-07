{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkIf
    elem
    ;
  nvidiaEnabled = (elem "nvidia" config.services.xserver.videoDrivers);
  cfgGraphics = config.hardware.graphics;
in
{
  config = mkIf nvidiaEnabled {
    boot.initrd.kernelModules = [ "nvidia" ];
    boot.extraModulePackages = [ config.hardware.nvidia.package ];

    # Settings for mobile NVIDIA
    hardware.graphics = mkIf cfgGraphics.enable {
      extraPackages = [
        (if pkgs ? libva-vdpau-driver then pkgs.libva-vdpau-driver else pkgs.vaapiVdpau) # LIBVA_DRIVER_NAME = "vdpau"
      ];
      extraPackages32 = [
        (
          if pkgs.driversi686Linux ? libva-vdpau-driver then
            pkgs.driversi686Linux.libva-vdpau-driver
          else
            pkgs.driversi686Linux.vaapiVdpau
        ) # LIBVA_DRIVER_NAME = "vdpau"
      ];
    };
  };
}
