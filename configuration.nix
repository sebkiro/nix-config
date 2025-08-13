{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./wireguard.nix
      ./backup.nix
      ./firejail.nix
      ./btrfs.nix
      ./power.nix
    ];

  boot.tmp.cleanOnBoot = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.udev.packages = [ pkgs.yubikey-personalization ];

  i18n.inputMethod.type = "ibus";

  # HW ACCEL
  nixpkgs.config.packageOverrides = pkgs: {
    intel-vaapi-driver = pkgs.intel-vaapi-driver.override { enableHybridCodec = true; };
  };

  environment.sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; };
  # HW ACCEL END


  programs.virt-manager.enable = true;
  users.groups.libvirtd.members = [ "shafner" ];
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  networking.hostName = "X1";

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      libvdpau-va-gl
    ];
  };

  fonts.packages = [
    pkgs.nerd-fonts.caskaydia-mono
  ];

  networking.networkmanager.enable = true;
  services.blueman.enable = true;

  time.timeZone = "Europe/Zurich";

  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_CH.UTF-8";
    LC_IDENTIFICATION = "de_CH.UTF-8";
    LC_MEASUREMENT = "de_CH.UTF-8";
    LC_MONETARY = "de_CH.UTF-8";
    LC_NAME = "de_CH.UTF-8";
    LC_NUMERIC = "de_CH.UTF-8";
    LC_PAPER = "de_CH.UTF-8";
    LC_TELEPHONE = "de_CH.UTF-8";
    LC_TIME = "de_CH.UTF-8";
  };

  services.xserver.enable = true;
  
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome = {
    enable = true;
  #  extraGSettingsOverridePackages = [ pkgs.mutter ];
  #  extraGSettingsOverrides = ''
  #    [org.gnome.mutter]
  #    experimental-features=['scale-monitor-framebuffer']
  #  '';
  };

  services.xserver.xkb = {
    layout = "ch";
    variant = "de_nodeadkeys";
  };

  console.keyMap = "sg";

  hardware.sane.enable = true;
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      cups-filters
      cups-browsed
      cnijfilter2
    ];
  };

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users.shafner = {
    isNormalUser = true;
    description = "Sebastian Hafner";
    extraGroups = [ "networkmanager" "libvirtd" "i2c" "scanner" "lp" ];
    shell = pkgs.zsh;
  };

  users.users.l-admin = {
    isNormalUser = true;
    description = "Local Administrator";
    extraGroups = [ "wheel" ];
    packages = with pkgs; [

    ];
  };
  systemd.tmpfiles.settings = {
    "l-admin-no-display-on-login" = {
      "/var/lib/AccountsService/users/l-admin".f = {
        type = "f+";
        argument = "[User]\nSession=\nIcon=/var/empty/.face\nSystemAccount=true";
      };
    };
  };

  programs.gpu-screen-recorder.enable = true;
  programs.zsh = {
    enable = true;
    ohMyZsh = {
      enable = true;
      theme = "miloshadzic";
    };
    autosuggestions.enable = true;
  };
  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    lfs = {
      enable = true;
    };
  };

  services.earlyoom.enable = true;
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    ansible
    libnotify
    libheif
    libwebp

    wasmtime

    solaar
    ddcutil
    gpu-screen-recorder-gtk

    rnote

    google-chrome
    libreoffice
    ffmpeg

    kew
    yewtube
    vlc

    nvd
    nil # Nix language server
    nixfmt-rfc-style
    htop
    powertop

    lm_sensors
    intel-gpu-tools
    pciutils
    usbutils
    unixtools.xxd
    dig

    _1password-gui

    nodejs_22
    yarn
    libsecret
    keepassxc

    (pkgs.buildFHSEnv {
      name = "rider";
      targetPkgs = pkgs: with pkgs; [
        jetbrains.rider
        (python3.withPackages (python-pkgs: with python-pkgs; [
          # select Python packages here
          pandas
          requests
          redis
        ]))
        (with dotnetCorePackages; combinePackages [
          sdk_8_0
        ])
        powershell
      ];
      profile = ''export FHS=1'';
      runScript = "rider";
    })

    (pkgs.buildFHSEnv {
      name = "goland";
      targetPkgs = pkgs: with pkgs; [
        jetbrains.goland
        go
      ];
      profile = ''export FHS=1'';
      runScript = "goland";
    })
    
    (pkgs.buildFHSEnv {
      name = "webstorm";
      targetPkgs = pkgs: with pkgs; [
        jetbrains.webstorm
      ];
      profile = ''export FHS=1'';
      runScript = "webstorm";
    })

    (pkgs.buildFHSEnv {
      name = "code";
      targetPkgs = pkgs: with pkgs; [
        vscode
        (python3.withPackages (python-pkgs: with python-pkgs; [
          # select Python packages here
          pandas
          requests
          redis
        ]))
        (with dotnetCorePackages; combinePackages [
          sdk_8_0
        ])
        powershell
      ];
      profile = ''export FHS=1'';
      runScript = "code";
    })


    postman
    obsidian
    zettlr
    element-desktop
    spotify
    gnome-sound-recorder
    powershell
    go
    git-lfs
    (with dotnetCorePackages; combinePackages [
      sdk_8_0
    ])
    citrix_workspace

    (whitesur-icon-theme.override {
      alternativeIcons = false;
      boldPanelIcons = true;
      themeVariants = [ "default" "grey" ];
    })
    (whitesur-gtk-theme.override {
      nautilusStyle = "glassy";
      iconVariant = "simple";
      #nautilusSize = "260";
      altVariants = [ "alt" ];
      themeVariants = [ "default" "blue" "grey" ];
      #nordColor = true;
      darkerColor = true;
      #colorVariants = [ "all" ];
      #opacityVariants = [ "all" ];
    })
    gnome-tweaks
    gnome-extension-manager
    gnomeExtensions.user-themes
    pantheon.elementary-wallpapers
    android-tools
  ];


  networking.firewall.allowedTCPPorts = [ ];
  networking.firewall.allowedUDPPorts = [ ];
  networking.firewall.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?


  services.xserver.excludePackages = [ pkgs.xterm ];
  environment.gnome.excludePackages = [
    pkgs.epiphany
    pkgs.yelp
    pkgs.geary
    pkgs.gnome-weather
    pkgs.gnome-maps
    pkgs.gnome-calendar
    pkgs.gnome-contacts
    pkgs.gnome-disk-utility
    pkgs.gnome-music
    pkgs.gnome-connections
    pkgs.gnome-clocks
    pkgs.gnome-tour
  ];

  networking.extraHosts = ''
    127.0.0.1 redis-single-master
    127.0.0.1 backrest-server
  '';
}
