{ pkgs, ... }:
{
  services = {
    gvfs.enable = true;
    samba-wsdd.enable = true;
  };

  environment.systemPackages = with pkgs; [
    samba
    cifs-utils
  ];

  programs.dconf.enable = true;
  security.polkit.enable = true;
}
