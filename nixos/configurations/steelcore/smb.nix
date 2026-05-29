{ ... }:
let
  hostname = "steelcore";
  workgroup = "WORKGROUP";
in
{
  services = {
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;

      publish = {
        enable = true;
        addresses = true;
        workstation = true;
      };
    };

    samba = {
      enable = true;
      openFirewall = true;
      settings = {
        global = {
          "workgroup" = workgroup;
          "server string" = hostname;
          "netbios name" = hostname;

          "security" = "user";
          "map to guest" = "bad user";

          "server min protocol" = "SMB2";
          "server max protocol" = "SMB3";
        };

        Archive = {
          "path" = "/media/archive";
          "browseable" = "yes";
          "writable" = "yes";
          "read only" = "no";
          "guest ok" = "no";

          "create mask" = "0770";
          "directory mask" = "0770";

          "valid users" = "simcra";
        };

        Storage = {
          "path" = "/media/storage";
          "browseable" = "yes";
          "writable" = "yes";
          "read only" = "no";
          "guest ok" = "no";

          "create mask" = "0770";
          "directory mask" = "0770";

          "valid users" = "simcra darkcrystal";
        };
      };
    };

    samba-wsdd = {
      enable = true;
      openFirewall = true;
    };
  };
}
