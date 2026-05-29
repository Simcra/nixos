{ pkgs, ... }:
{
  systemd.user.services.onedrive = {
    Unit = {
      Description = "OneDrive sync client";
    };

    Service = {
      ExecStart = "${pkgs.unstable.onedrive}/bin/onedrive --monitor";
      Restart = "on-failure";
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
