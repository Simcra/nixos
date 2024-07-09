{ lib, pkgs, ... }:
{
  imports = [ ./defaults.nix ];

  # Enable power management for mobile GPUs
  hardware.nvidia.powerManagement.enable = lib.mkDefault true;

  # Add the VDPAU driver packages
  hardware.opengl = {
    extraPackages = [
      (if pkgs ? libva-vdpau-driver
      then pkgs.libva-vdpau-driver
      else pkgs.vaapiVdpau)
    ];

    extraPackages32 = [
      (if pkgs.driversi686Linux ? libva-vdpau-driver
      then pkgs.driversi686Linux.libva-vdpau-driver
      else pkgs.driversi686Linux.vaapiVdpau)
    ];
  };
}
