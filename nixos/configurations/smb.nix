{ pkgs, ... }:
{
  programs.dconf.enable = true;
  security.polkit.enable = true;

  services = {
    gvfs.enable = true;
    samba-wsdd.enable = true;
  };

  environment.systemPackages = with pkgs; [
    cifs-utils
    samba
  ];
}
