{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    rclone
    restic
    backrest
  ];

  systemd.services.backrest = {
    enable = true;
    description = "Backrest Service";
    requires = [ "network-online.target" ];
    wantedBy = [ "default.target" ];
    serviceConfig = {
      User = "shafner";
      Group = "users";
      Environment = [
        "BACKREST_PORT=127.0.0.1:9898"
        "BACKREST_RESTIC_COMMAND=${pkgs.restic}/bin/restic"
      ];
      ExecStart = "${pkgs.backrest}/bin/backrest";
    };
  };
}
