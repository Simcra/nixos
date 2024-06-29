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
    extraPackages = with pkgs; [ (if libva-vdpau-driver then libva-vdpau-driver else vaapiVdpau) ];
    extraPackages32 = with pkgs.driversi686Linux; [ (if libva-vdpau-driver then libva-vdpau-driver else vaapiVdpau) ];
  };
}
