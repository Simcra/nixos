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

    maxPlayers = lib.mkOption {
      type = lib.types.ints.positive;
      default = 32;
      description = "Maximum number of players";
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

        # Palworld expects the Steam SDK libraries in ~/.steam.
        mkdir -p ${cfg.homeDir}/.steam

        if [ ! -e ${cfg.homeDir}/.steam/sdk32 ]; then
          ln -s ${cfg.homeDir}/.steam/steam/steamcmd/linux32 ${cfg.homeDir}/.steam/sdk32
        fi

        mkdir -p ${cfg.installDir}/Pal/Saved/Config/LinuxServer
        if [ ! -f ${cfg.installDir}/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini ]; then
          cp ${cfg.installDir}/DefaultPalWorldSettings.ini ${cfg.installDir}/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
        fi
      '';

      script =
        let
          publicLobbyArg = lib.optionalString cfg.publicLobby "-publiclobby";
          publicIpArg = lib.optionalString (cfg.publicIp != null) "-publicip=${cfg.publicIp}";
          publicPortArg = lib.optionalString (
            cfg.publicPort != null
          ) "-publicport=${toString cfg.publicPort}";
        in
        ''exec ${cfg.installDir}/PalServer.sh -port=${toString cfg.port} -players=${toString cfg.maxPlayers} ${publicLobbyArg} ${publicIpArg} ${publicPortArg} ${cfg.extraServerArgs}'';

      serviceConfig = {
        Restart = "always";
        RestartSec = 10;

        User = cfg.serviceUser;
        Group = cfg.serviceGroup;
        SupplementaryGroups = cfg.serviceExtraGroups;

        WorkingDirectory = cfg.installDir;
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
