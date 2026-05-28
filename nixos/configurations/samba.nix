{ pkgs, ... }:
{
  services = {
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    gvfs.enable = true;
    samba.enable = true;
    samba-wsdd.enable = true;
  };

  environment.systemPackages = with pkgs; [
    samba
    cifs-utils
  ];

  programs.dconf.enable = true;
  security.polkit.enable = true;
}
