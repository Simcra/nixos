{ config, lib, ... }: {
  imports = [
    ./nvidia-gpu.nix
  ];

  # NVIDIA settings
  hardware.nvidia = {
    # Disable power mangement, this causes a lot of performance issues with NVIDIA desktop GPUs 
    powerManagement = {
      enable = lib.mkDefault false;
      finegrained = lib.mkDefault false;
    };
  };

  # Enable the xserver video driver
  services.xserver.videoDrivers =
    if config.hardware.nvidia.driver == "nvidia"
    then [ "nvidia" ]
    else [ ];
}
