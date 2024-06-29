{ config, lib, ... }:
{
  # Add initrd kernel modules and extra module packages
  boot.initrd.kernelModules = [ "nvidia" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];

  # Enable OpenGL with both 32-bit and 64-bit driver support
  hardware.opengl = {
    enable = lib.mkDefault true;
    driSupport = lib.mkDefault true;
    driSupport32Bit = lib.mkDefault true;
  };

  # NVIDIA settings
  hardware.nvidia = {
    # Enable modesettings, required for most NVIDIA GPUs
    modesetting.enable = lib.mkDefault true;

    # Use the proprietary closed-source drivers, because they typically work better
    open = lib.mkDefault false;

    # Enable the NVIDIA settings application
    nvidiaSettings = lib.mkDefault true;

    # Use the "stable" branch of the NVIDIA drivers
    package = lib.mkDefault config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Enable xserver video driver
  services.xserver.videoDrivers = lib.mkDefault [ "nvidia" ];
}
