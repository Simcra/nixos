{ pkgs, ... }:
{
  # Install MegaCLI for systems with a MegaRAID SAS card
  environment.systemPackages = with pkgs; [
    megacli
  ];
}
