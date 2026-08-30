{
  config,
  lib,
  pkgs,
  ...
}:
let
  service = "palworld-dedicated-server";
  serviceName = "Palworld Dedicated Server";
  backupService = "${service}-backup";
  backupServiceName = "${serviceName} Backup Process";
  cfg = config.services.${service};
in
{
  options.services.${service} = {
    enable = lib.mkEnableOption "Enable ${serviceName}";

    serviceUser = lib.mkOption {
      type = lib.types.str;
      default = "palworld";
      description = "Service user for ${serviceName}";
    };

    serviceGroup = lib.mkOption {
      type = lib.types.str;
      default = cfg.serviceUser;
      description = "Primary group for the ${serviceName} service user";
    };

    serviceExtraGroups = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Extra groups for the ${serviceName} service user";
    };

    homeDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/${cfg.serviceUser}";
      description = "Home directory of the ${serviceName} service user";
    };

    installDir = lib.mkOption {
      type = lib.types.path;
      default = "${cfg.homeDir}/PalworldDedicatedServer";
      description = "Installation directory of the ${serviceName} binaries";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Open ports in the firewall for the ${serviceName}";
    };

    backups = {
      enable = lib.mkEnableOption "Enable ${serviceName} periodic backup service";

      dir = lib.mkOption {
        type = lib.types.path;
        default = "/var/backups/${cfg.serviceUser}";
        description = "Directory where the ${serviceName} backups will be stored";
      };

      period = lib.mkOption {
        type = lib.types.str;
        default = "daily";
        description = "Period to use for scheduling the systemd OnCalender backup process";
        example = "hourly";
      };

      retention = lib.mkOption {
        type = lib.types.int;
        default = 7;
        description = "Number of backups to retain before discarding the oldest backup";
      };
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8211;
      description = "UDP port used by the Palworld server";
    };

    serverName = lib.mkOption {
      type = lib.types.str;
      default = "Default Palworld Server";
      description = "The name of the server advertised in the community server browser";
    };

    serverDescription = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "The description of the server advertised in the community server browser";
    };

    publicLobby = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Advertise the server as a community server";
    };

    publicIp = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Public IP address advertised by a community server";
    };

    publicPort = lib.mkOption {
      type = lib.types.nullOr lib.types.port;
      default = null;
      description = "Public port advertised by a community server";
    };

    maxPlayers = lib.mkOption {
      type = lib.types.ints.positive;
      default = 32;
      description = "Maximum number of players";
    };

    allowClientMods = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to allow modified clients to connect to the server";
    };

    showPlayerList = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to show the list of players connected to the server";
    };

    extraServerArgs = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Extra arguments passed to PalServer.sh";
    };
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.config.allowUnfree = true;

    users.users.${cfg.serviceUser} = {
      home = cfg.homeDir;
      createHome = true;
      isSystemUser = true;
      group = cfg.serviceGroup;
      extraGroups = cfg.serviceExtraGroups;
    };
    users.groups.${cfg.serviceGroup} = { };

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedUDPPorts = [
        cfg.port
      ];
    };

    systemd.services.${service} = {
      description = serviceName;
      wantedBy = [ "multi-user.target" ];

      preStart = ''
        ${pkgs.steamcmd}/bin/steamcmd \
          +force_install_dir ${cfg.installDir} \
          +login anonymous \
          +app_update 2394010 validate \
          +quit

        ${pkgs.patchelf}/bin/patchelf --set-interpreter ${pkgs.glibc}/lib/ld-linux-x86-64.so.2 ${cfg.installDir}/Pal/Binaries/Linux/PalServer-Linux-Shipping
        ${pkgs.patchelf}/bin/patchelf \
          --set-interpreter ${pkgs.glibc}/lib/ld-linux-x86-64.so.2 \
          --set-rpath "${
            lib.makeLibraryPath [
              pkgs.curl
              pkgs.zlib
              pkgs.stdenv.cc.cc
            ]
          }:${cfg.installDir}/Pal/Binaries/Linux" \
          ${cfg.installDir}/Pal/Plugins/Sentry/Binaries/Linux/crashpad_handler
        ln -sfv ${cfg.homeDir}/.steam/steam/linux64 ${cfg.homeDir}/.steam/sdk64

        mkdir -p ${cfg.installDir}/Pal/Saved/Config/LinuxServer
        if [ ! -f ${cfg.installDir}/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini ]; then
          cp ${cfg.installDir}/DefaultPalWorldSettings.ini ${cfg.installDir}/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
        fi
        ${pkgs.crudini}/bin/crudini --set ${cfg.installDir}/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini '/Script/Pal.PalGameWorldSettings' ServerName '${cfg.serverName}'
        ${pkgs.crudini}/bin/crudini --set ${cfg.installDir}/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini '/Script/Pal.PalGameWorldSettings' ServerDescription '${cfg.serverDescription}'
        ${pkgs.crudini}/bin/crudini --set ${cfg.installDir}/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini '/Script/Pal.PalGameWorldSettings' bAllowClientMod ${
          if cfg.allowClientMods then "True" else "False"
        }
        ${pkgs.crudini}/bin/crudini --set ${cfg.installDir}/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini '/Script/Pal.PalGameWorldSettings' bShowPlayerList ${
          if cfg.showPlayerList then "True" else "False"
        }
      '';

      script =
        let
          publicLobbyArg = lib.optionalString cfg.publicLobby "-publiclobby";
          publicIpArg = lib.optionalString (cfg.publicIp != null) "-publicip=${cfg.publicIp}";
          publicPortArg = lib.optionalString (
            cfg.publicPort != null
          ) "-publicport=${toString cfg.publicPort}";
        in
        ''
          exec ${cfg.installDir}/PalServer.sh \
                    -port=${toString cfg.port} \
                    -players=${toString cfg.maxPlayers} \
                    ${publicLobbyArg} \
                    ${publicIpArg} \
                    ${publicPortArg} \
                    ${cfg.extraServerArgs}'';

      serviceConfig = {
        Restart = "always";
        RestartSec = 10;

        User = cfg.serviceUser;
        Group = cfg.serviceGroup;
        SupplementaryGroups = cfg.serviceExtraGroups;

        WorkingDirectory = cfg.installDir;
      };

      environment = {
        LD_LIBRARY_PATH = lib.concatStringsSep ":" [
          "${cfg.installDir}/linux64"
          "${cfg.installDir}/Pal/Binaries/Linux"
          "${cfg.installDir}/Engine/Binaries/Linux"
        ];
      };
    };

    systemd.services.${backupService} = lib.mkIf cfg.backups.enable {
      description = backupServiceName;

      serviceConfig = {
        Type = "oneshot";

        User = cfg.serviceUser;
        Group = cfg.serviceGroup;
        SupplementaryGroups = cfg.serviceExtraGroups;

        ReadWritePaths = [
          (lib.escapeShellArg cfg.homeDir)
          (lib.escapeShellArg cfg.backups.dir)
        ];
      };

      script =
        let
          sourceFolder = "${cfg.installDir}/Pal/Saved/SaveGames";
          destinationFolder = "${cfg.backups.dir}/${builtins.baseNameOf cfg.installDir}";
          outputFilePrefix = "palworld";
        in
        ''
          set -euo pipefail

          SRC="${sourceFolder}"
          DST="${destinationFolder}"
          TIMESTAMP="$(date +%Y-%m-%d_%H-%M-%S)"
          OUT="$DST/${outputFilePrefix}-$TIMESTAMP.tar.zst"

          if [ ! -d "$DST" ]; then
            mkdir -p "$DST"
            chmod --reference="$(dirname "$DST")" "$DST"
          fi

          if [ ! -d "$SRC" ]; then
            echo "${backupService}: cannot access source directory '$SRC': No such file or directory"
            exit 1
          fi

          "${pkgs.gnutar}/bin/tar" \
            --use-compress-program=${pkgs.zstd}/bin/zstd \
            -cf "$OUT" \
            -C "$SRC" .
          chmod --reference="$(dirname "$OUT")" "$OUT"

          ls -1t "$DST"/${outputFilePrefix}-*.tar.zst 2>/dev/null \
            | tail -n +${toString (cfg.backups.retention + 1)} \
            | xargs -r rm -f
        '';
    };

    systemd.timers.${backupService} = lib.mkIf cfg.backups.enable {
      description = "${backupServiceName} Timer";

      wantedBy = [ "timers.target" ];

      timerConfig = {
        OnCalendar = cfg.backups.period;
        Persistent = true;
        Unit = "${backupService}.service";
      };
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.homeDir} 0750 ${cfg.serviceUser} ${cfg.serviceGroup} -"
      "d ${cfg.installDir} 0750 ${cfg.serviceUser} ${cfg.serviceGroup} -"
    ];
  };
}
