{ pkgs, ... }:

{
  systemd.services.fire-lobby = {
    description = "Firesquare lobby";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      Type = "simple";
      User = "fire-lobby";
      Group = "fire-minecraft";
      ExecStart = pkgs.mineflake.buildMineflakeBin {
        type = "spigot";
        command = "${pkgs.jre_headless}/bin/java -Xms1G -Xmx1G -jar {} nogui";
        package = pkgs.mineflake.paper;
      };
      WorkingDirectory = "/var/lib/fire-lobby";
    };
  };

  users.users.fire-lobby = {
    isSystemUser = true;
    group = "fire-minecraft";
    home = "/var/lib/fire-lobby";
  };

  users.groups.fire-minecraft = { };
}
