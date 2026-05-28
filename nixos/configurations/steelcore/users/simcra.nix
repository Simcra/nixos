{ ... }:
{
  imports = [ ../../../users/simcra.nix ];

  # Add extra groups
  extraGroups = [
    "archive"
    "wheel"
  ];
}
