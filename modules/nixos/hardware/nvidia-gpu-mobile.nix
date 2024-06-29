{ lib, pkgs, ... }: {
  imports = [
    ./nvidia-gpu.nix
  ];

  # NVIDIA settings
  hardware.nvidia = {
    # Enable power management for mobile devices
    powerManagement.enable = lib.mkDefault true;
  };

  # Add the OpenGL/Graphics driver packages
  hardware.opengl = {
    extraPackages = [
      (if pkgs.libva-vdpau-driver
      then pkgs.libva-vdpau-driver
      else pkgs.vaapiVdpau)
    ];
    extraPackages32 = [
      (if pkgs.driversi686Linux.libva-vdpau-driver
      then pkgs.driversi686Linux.libva-vdpau-driver
      else pkgs.driversi686Linux.vaapiVdpau)
    ];
  };
}
