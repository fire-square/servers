{ pkgs, mineflake, ... }:

let
  paperCommon = {
    type = "spigot";
    command = "${pkgs.jre_headless}/bin/java -Xms1G -Xmx1G -jar {} nogui";
    package = pkgs.mineflake.paper;
    permissions = permissions;
    # plugins = with pkgs.mineflake; [
    #   luckperms
    # ];
  };

  permissions = [
    {
      name = "default";
      permissions = [ ];
    }
    {
      name = "admin";
      permissions = [ "luckperms.*" ];
    }
  ];

  commonPaperConfigs = [
    (pkgs.mineflake.mkMfConfig "mergeyaml" "spigot.yml" {
      settings = {
        restart-on-crash = false;
        bungeecord = true;
      };
    })
    (pkgs.mineflake.mkMfConfig "mergeyaml" "plugins/LuckPerms/config.yml" {
      storage-method = "json";
      data = {
        address = "127.0.0.1";
        database = "luckperms";
        username = "firesquare";
        password = "changeme";
        table-prefix = "";
        sync-minutes = 15;
      };
      split-storage = {
        enabled = true;
        methods = {
          user = "mysql";
          group = "json";
          track = "json";
          uuid = "mysql";
          log = "mysql";
        };
      };
      messaging-service = "sql";
      temporary-add-behaviour = "accumulate";
      enable-ops = false;
      auto-op = true;
      prevent-primary-group-removal = true;
    })
  ];

  commonService = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" "mysql.service" ];
    serviceConfig = {
      Type = "simple";
      Group = "fire-minecraft";
      # EnvironmentFile = "/run/passwords.env";
      # PassEnvironment = "DB_PASSWORD";
    };
  };

  lobby = pkgs.mineflake.buildMineflakeBin (paperCommon // {
    plugins = with pkgs.mineflake; [
      luckperms
    ];
    configs = commonPaperConfigs ++ [
      (pkgs.mineflake.mkMfConfig "raw" "server.properties" ''
        enable-command-block=false
        server-ip=0.0.0.0
        server-port=25000
        query.port=25000
        online-mode=false
      '')
    ];
  });

  vanilla = pkgs.mineflake.buildMineflakeBin (paperCommon // {
    plugins = with pkgs.mineflake; [
      coreprotect
      luckperms
    ];
    configs = commonPaperConfigs ++ [
      (pkgs.mineflake.mkMfConfig "raw" "server.properties" ''
        enable-command-block=false
        server-ip=0.0.0.0
        server-port=25001
        query.port=25001
        online-mode=false
      '')
    ];
  });

  proxy = pkgs.mineflake.buildMineflakeBin {
    type = "bungee";
    command = "${pkgs.jre_headless}/bin/java -Xms1G -Xmx1G -jar {}";
    package = pkgs.mineflake.waterfall;
    configs = [
      (pkgs.mineflake.mkMfConfig "mergeyaml" "config.yml" {
        online_mode = false;
        ip_forward = true;
        player_limit = 20;
        listeners = [
          {
            host = "0.0.0.0:25565";
            query_port = 25565;
            motd = "&1Firesquare V2!";
            max_players = 20;
            forced_hosts = { };
            query_enabled = true;
            priorities = [ "lobby" ];
          }
        ];
        servers = {
          lobby = {
            address = "127.0.0.1:25000";
          };
          vanilla = {
            address = "127.0.0.1:25001";
          };
        };
      })
    ];
  };
in
{
  systemd.services.fire-lobby = commonService // {
    description = "Firesquare lobby";
    serviceConfig = {
      ExecStart = "${lobby}/bin/mineflake";
      User = "fire-lobby";
      WorkingDirectory = "/var/lib/fire-lobby";
    };
  };

  users.users.fire-lobby = {
    isSystemUser = true;
    createHome = true;
    group = "fire-minecraft";
    home = "/var/lib/fire-lobby";
  };

  systemd.services.fire-vanilla = commonService // {
    description = "Firesquare lobby";
    serviceConfig = {
      ExecStart = "${vanilla}/bin/mineflake";
      User = "fire-vanilla";
      WorkingDirectory = "/var/lib/fire-vanilla";
    };
  };

  users.users.fire-vanilla = {
    isSystemUser = true;
    createHome = true;
    group = "fire-minecraft";
    home = "/var/lib/fire-vanilla";
  };

  systemd.services.fire-proxy = commonService // {
    description = "Firesquare proxy";
    serviceConfig = {
      ExecStart = "${proxy}/bin/mineflake";
      User = "fire-proxy";
      WorkingDirectory = "/var/lib/fire-proxy";
    };
  };

  users.users.fire-proxy = {
    isSystemUser = true;
    createHome = true;
    group = "fire-minecraft";
    home = "/var/lib/fire-proxy";
  };

  users.groups.fire-minecraft = { };

  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    settings = {
      mysqld = {
        max_connections = 512;
      };
    };
    ensureDatabases = [ "luckperms" ];
    ensureUsers = [{
      name = "firesquare";
      ensurePermissions = {
        "luckperms.*" = "ALL PRIVILEGES";
      };
    }];
  };
}
