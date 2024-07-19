{ config, lib, pkgs, ... }:
let
  inherit (lib)
    mkDefault
    mkOverride
    mkIf
    elem;
  nvidiaEnabled = (elem "nvidia" config.services.xserver.videoDrivers);
  cfgGraphics = config.hardware.graphics;
in
{
  imports = [ ./. ];

  config = mkIf nvidiaEnabled {
    boot.initrd.kernelModules = [ "nvidia" ];
    boot.extraModulePackages = [ config.hardware.nvidia.package ];

    hardware.graphics = mkIf cfgGraphics.enable {
      extraPackages =
        if pkgs ? libva-vdpau-driver
        then with pkgs; [ libva-vdpau-driver nvidia-vaapi-driver ]
        else with pkgs; [ vaapiVdpau nvidia-vaapi-driver ];
      extraPackages32 =
        if pkgs.driversi686Linux ? libva-vdpau-driver
        then with pkgs.driversi686Linux; [ libva-vdpau-driver ]
        else with pkgs.driversi686Linux; [ vaapiVdpau ];
    };

    environment.variables = {
      LIBVA_DRIVER_NAME = mkOverride 990 "nvidia";
      VDPAU_DRIVER = mkIf cfgGraphics.enable (mkDefault "va_gl");
    };
  };
}
