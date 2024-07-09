{ lib, ... }:
{
  imports = [ ./defaults.nix ];

  # Disable power management for desktop GPUs, it causes a lot of performance issues
  hardware.nvidia.powerManagement.enable = lib.mkDefault false;
}
