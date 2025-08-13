{ config, pkgs, ... }:

{
  programs.firefox.enable = true;
  programs.firejail = {
    enable = false;
    wrappedBinaries = {
      firefox = {
        executable = "${pkgs.firefox}/bin/firefox";
        profile = "${pkgs.firejail}/etc/firejail/firefox.profile";
        desktop = "${pkgs.firefox}/share/applications/firefox.desktop";
        extraArgs = [
          # Required for U2F USB stick
          "--ignore=private-dev"
          # Enforce dark mode
          "--env=GTK_THEME=Adwaita:dark"
          # Enable system notifications
          "--dbus-user.talk=org.freedesktop.Notifications"
        ];
      };
    };
  };
}
