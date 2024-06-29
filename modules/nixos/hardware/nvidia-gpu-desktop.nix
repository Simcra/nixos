{ config, lib, ... }: {
  imports = [
    ./nvidia-gpu.nix
  ];

  # Add initrd kernel modules and extra module packages
  boot.initrd.kernelModules = [ "nvidia" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];

  # NVIDIA settings
  hardware.nvidia = {
    # Disable power mangement, this causes a lot of performance issues with NVIDIA desktop GPUs 
    powerManagement = {
      enable = lib.mkDefault false;
      finegrained = lib.mkDefault false;
    };
  };

  # Enable xserver video driver
  services.xserver.videoDrivers = lib.mkDefault [ "nvidia" ];
}
