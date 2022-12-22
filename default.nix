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
  };

  proxy = pkgs.mineflake.buildMineflakeBin {
    type = "bungee";
    command = "${pkgs.jre_headless}/bin/java -Xms1G -Xmx1G -jar {}";
    package = pkgs.mineflake.waterfall;
    # plugins = with pkgs.mineflake; [
      # luckperms
    # ];
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
      WorkingDirectory = "/var/lib/fire-lobby";
    };
  };

  users.users.fire-lobby = {
    isSystemUser = true;
    createHome = true;
    group = "fire-minecraft";
    home = "/var/lib/fire-lobby";
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
}
