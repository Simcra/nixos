{
  config,
  lib,
  pkgs,
  ...
}:
let
  service = "satisfactory-dedicated-server";
  serviceName = "Satisfactory Dedicated Server";
  backupService = "${service}-backup";
  backupServiceName = "${serviceName} Backup Process";
  cfg = config.services.${service};
in
{
  options.services.${service} = {
    enable = lib.mkEnableOption "Enable ${serviceName}";

    serviceUser = lib.mkOption {
      type = lib.types.str;
      default = "satisfactory";
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
      default = "${cfg.homeDir}/SatisfactoryDedicatedServer";
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

    beta = lib.mkOption {
      type = lib.types.enum [
        "public"
        "experimental"
      ];
      default = "public";
      description = "Beta channel to follow";
    };

    address = lib.mkOption {
      type = lib.types.str;
      default = "0.0.0.0";
      description = "Bind address";
    };

    maxPlayers = lib.mkOption {
      type = lib.types.number;
      default = 4;
      description = "Number of players";
    };

    autoPause = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Auto pause when no players are online";
    };

    autoSaveOnDisconnect = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Auto save on player disconnect";
    };

    extraSteamCmdArgs = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Extra arguments passed to steamcmd command";
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
        7777
        15000
        15777
      ];
      allowedTCPPorts = [
        7777
        8888
      ];
    };

    systemd.services.${service} = {
      description = serviceName;
      wantedBy = [ "multi-user.target" ];

      preStart = ''
        ${pkgs.steamcmd}/bin/steamcmd \
          +force_install_dir ${cfg.installDir} \
          +login anonymous \
          +app_update 1690800 validate \
          -beta ${cfg.beta} \
          ${cfg.extraSteamCmdArgs} \
          +quit
        ${pkgs.patchelf}/bin/patchelf --set-interpreter ${pkgs.glibc}/lib/ld-linux-x86-64.so.2 ${cfg.installDir}/Engine/Binaries/Linux/FactoryServer-Linux-Shipping
        ln -sfv ${cfg.homeDir}/.steam/steam/linux64 ${cfg.homeDir}/.steam/sdk64
        mkdir -p ${cfg.installDir}/FactoryGame/Saved/Config/LinuxServer
        ${pkgs.crudini}/bin/crudini --set ${cfg.installDir}/FactoryGame/Saved/Config/LinuxServer/Game.ini '/Script/Engine.GameSession' MaxPlayers ${toString cfg.maxPlayers}
        ${pkgs.crudini}/bin/crudini --set ${cfg.installDir}/FactoryGame/Saved/Config/LinuxServer/ServerSettings.ini '/Script/FactoryGame.FGServerSubsystem' mAutoPause ${
          if cfg.autoPause then "True" else "False"
        }
        ${pkgs.crudini}/bin/crudini --set ${cfg.installDir}/FactoryGame/Saved/Config/LinuxServer/ServerSettings.ini '/Script/FactoryGame.FGServerSubsystem' mAutoSaveOnDisconnect ${
          if cfg.autoSaveOnDisconnect then "True" else "False"
        }
      '';

      script = ''
        ${cfg.installDir}/Engine/Binaries/Linux/FactoryServer-Linux-Shipping FactoryGame -multihome=${cfg.address}
      '';

      serviceConfig = {
        Restart = "always";

        User = cfg.serviceUser;
        Group = cfg.serviceGroup;
        SupplementaryGroups = cfg.serviceExtraGroups;

        WorkingDirectory = cfg.installDir;
      };

      environment = {
        LD_LIBRARY_PATH = lib.concatStringsSep ":" [
          "${cfg.installDir}/linux64"
          "${cfg.installDir}/Engine/Binaries/Linux"
          "${cfg.installDir}/Engine/Binaries/ThirdParty/PhysX3/Linux/x86_64-unknown-linux-gnu"
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
          sourceFolder = "${cfg.homeDir}/.config/Epic/FactoryGame/Saved/SaveGames";
          destinationFolder = "${cfg.backups.dir}/${builtins.baseNameOf cfg.installDir}";
          outputFilePrefix = "satisfactory";
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
