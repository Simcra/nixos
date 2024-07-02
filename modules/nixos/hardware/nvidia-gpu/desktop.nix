{ lib, ... }:
{
  imports = [ ./common.nix ];

  # NVIDIA settings
  hardware.nvidia = {
    # Disable power mangement, this causes a lot of performance issues with NVIDIA desktop GPUs 
    powerManagement = {
      enable = lib.mkDefault false;
      finegrained = lib.mkDefault false;
    };
  };
}
