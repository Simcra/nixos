{ config, lib, ... }:
{
  # Add extra module packages
  boot.extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];

  # Install the initrd kernel module
  boot.initrd.kernelModules = [ "nvidia" ];

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

    # Disable finegrained power mangement by default, it is experimental and only works on modern GPUs (Turing or newer)
    powerManagement.finegrained = lib.mkDefault false;

    # Use the proprietary closed-source drivers, because they typically work better
    open = lib.mkDefault false;

    # Enable the NVIDIA settings application
    nvidiaSettings = lib.mkDefault true;

    # Use the "stable" branch of the NVIDIA drivers
    package = lib.mkDefault config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Enable the xserver video driver
  services.xserver.videoDrivers = [ "nvidia" ];
}
