{ pkgs, ... }:

let
  lobby = pkgs.mineflake.buildMineflakeBin {
    type = "spigot";
    command = "${pkgs.jre_headless}/bin/java -Xms1G -Xmx1G -jar {} nogui";
    package = pkgs.mineflake.paper;
    plugins = with pkgs.mineflake; [
      luckperms
      coreprotect
    ];
    configs = [
      (mineflake.mkMfConfig "raw" "server.properties" ''
        enable-command-block=false
        server-ip=0.0.0.0
        server-port=25000
        query.port=25000
        online-mode=false
      '')
    ];
  };

  proxy = pkgs.mineflake.buildMineflakeBin {
    type = "bungee";
    command = "${pkgs.jre_headless}/bin/java -Xms1G -Xmx1G -jar {}";
    package = pkgs.mineflake.waterfall;
    configs = [
      (mineflake.mkMfConfig "mergeyaml" "config.yml" {
        online_mode = false;
        listeners = [
          {
            host = "0.0.0.0:25565";
            query_port = 25565;
            motd = "&1Firesquare V2!";
            max_players = 20;
          }
        ];
        servers = {
          lobby = {
            address = "127.0.0.1:25000";
          };
        };
      })
    ];
  };
in
{
  systemd.services.fire-lobby = {
    description = "Firesquare lobby";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${lobby}/bin/mineflake";
      User = "fire-lobby";
      Group = "fire-minecraft";
      WorkingDirectory = "/var/lib/firesquare/lobby";
    };
  };

  users.users.fire-lobby = {
    isSystemUser = true;
    createHome = true;
    group = "fire-minecraft";
    home = "/var/lib/firesquare/lobby";
  };

  systemd.services.fire-proxy = {
    description = "Firesquare proxy";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${proxy}/bin/mineflake";
      User = "fire-proxy";
      Group = "fire-minecraft";
      WorkingDirectory = "/var/lib/firesquare/proxy";
    };
  };

  users.users.fire-proxy = {
    isSystemUser = true;
    createHome = true;
    group = "fire-minecraft";
    home = "/var/lib/firesquare/proxy";
  };

  users.groups.fire-minecraft = { };
}
