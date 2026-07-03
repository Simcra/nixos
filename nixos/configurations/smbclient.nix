{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkIf
    mkMerge
    optionals
    ;
  cfgDesktopEnv = config.desktop.environment;
in
{
  config = mkMerge [
    {
      security.polkit.enable = true;
      services.samba-wsdd.enable = true;

      environment.systemPackages =
        with pkgs;
        [
          cifs-utils
          samba
        ]
        ++ optionals (cfgDesktopEnv == "plasma") [
          kdePackages.kio-extras
          kdePackages.kio-fuse
        ];
    }

    (mkIf (cfgDesktopEnv == "gnome") {
      programs.dconf.enable = true;
      services.gvfs.enable = true;
    })
  ];
}
