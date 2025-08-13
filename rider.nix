{ pkgs, ... }:

# DEPRECATED, WILL BE REMOVED

let
  rider = pkgs.jetbrains.rider;

  # 1. Create an FHS-wrapped launcher for Rider
  riderFHS = pkgs.buildFHSUserEnv {
    name = "rider";
    targetPkgs = pkgs: with pkgs; [ rider ];
    runScript = "rider";
  };

  # 2. Wrap FHS + desktop entry in one derivation
  riderWithDesktop = pkgs.runCommand "rider-fulldesktop" {
    nativeBuildInputs = [ pkgs.makeWrapper ];
  } ''
    mkdir -p $out/bin
    mkdir -p $out/share/applications
    mkdir -p $out/share/icons

    # Symlink the wrapped executable
    ln -s ${riderFHS}/bin/rider $out/bin/rider

    # Copy and patch the existing .desktop file
    cp ${rider}/share/applications/rider.desktop $out/share/applications/rider.desktop

    # Symlink the icons (optional, desktop environments may fallback to the icon theme)
    cp -r ${rider}/share/icons/* $out/share/icons/ || true
  '';
in
{
  environment.systemPackages = [
    riderWithDesktop
  ];
}
