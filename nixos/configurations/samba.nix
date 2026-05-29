{ pkgs, ... }:
{
  programs.dconf.enable = true;
  security.polkit.enable = true;
  networking.networkmanager.dns = "systemd-resolved";

  services = {
    gvfs.enable = true;
    resolved = {
      enable = true;
      llmnr = "true";
    };
    samba-wsdd.enable = true;
  };

  environment.systemPackages = with pkgs; [
    cifs-utils
    samba
  ];
}
