{
  config,
  lib,
  pkgs,
  ...
}:
let
  service = "project-zomboid-dedicated-server";
  serviceName = "Project Zomboid Dedicated Server";
  cfg = config.services.${service};
in
{
  options.services.${service} = {
    enable = lib.mkEnableOption "Enable ${serviceName}";

    serviceUser = lib.mkOption {
      type = lib.types.str;
      default = "zomboid";
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
      default = "${cfg.homeDir}/ProjectZomboidDedicatedServer";
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
        "unstable"
      ];
      default = "public";
      description = "Beta channel to follow";
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
        16261
        16262
      ];
    };

    systemd.services.${service} = {
      description = serviceName;
      wantedBy = [ "multi-user.target" ];

      preStart = ''
        ${pkgs.steamcmd}/bin/steamcmd \
          +force_install_dir ${cfg.installDir} \
          +login anonymous \
          +app_update 380870 validate \
          -beta ${cfg.beta} \
          ${cfg.extraSteamCmdArgs} \
          +quit
        ln -sfv ${cfg.homeDir}/.steam/steam/linux64 ${cfg.homeDir}/.steam/sdk64
      '';

      script = ''
        exec ${cfg.installDir}/start-server.sh < ${cfg.installDir}/zomboid.control
      '';

      serviceConfig = {
        Type = "simple";
        Restart = "always";

        User = cfg.serviceUser;
        Group = cfg.serviceGroup;
        SupplementaryGroups = cfg.serviceExtraGroups;

        WorkingDirectory = cfg.installDir;
        PrivateTmp = true;

        Sockets = [ "zomboid.socket" ];
        KillSignal = "SIGCONT";

        ExecStop = pkgs.writeShellScript "zomboid-stop" ''
          echo save > ${cfg.installDir}/zomboid.control
          sleep 15
          echo quit > ${cfg.installDir}/zomboid.control
        '';
      };
    };

    systemd.sockets.zomboid = {
      description = "Project Zomboid control FIFO";

      bindsTo = [ "${service}.service" ];

      wantedBy = [ "sockets.target" ];

      socketConfig = {
        ListenFIFO = "${cfg.installDir}/zomboid.control";
        FileDescriptorName = "control";
        RemoveOnStop = true;
        SocketMode = "0660";
        SocketUser = cfg.serviceUser;
        SocketGroup = cfg.serviceGroup;
      };
    };
  };
}
