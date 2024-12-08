{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    cabextract
    p7zip
    wineWowPackages.stagingFull
    winetricks
  ];
}
