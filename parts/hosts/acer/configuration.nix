{
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./packages.nix
    ./keyboard.nix
    ./services.nix
    ./sops.nix
  ];

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.useOSProber = true;
  boot.loader.grub.default = "saved";
  boot.loader.grub.configurationLimit = 5;
  boot.loader.timeout = 2;
  boot.plymouth.enable = true;
  boot.kernelParams = [
    "quiet"
  ];
  #boot.consoleLogLevel = 1;

  networking.hostName = "nixos"; # Define your hostname.
  networking.networkmanager.enable = true;
  networking.networkmanager.ensureProfiles.environmentFiles = [
    config.sops.secrets.home_wifi_1.path
    config.sops.secrets.home_wifi_2.path
  ];
  networking.networkmanager.ensureProfiles.profiles = {
    Telenet0706906 = {
      connection = {
        id = "Telenet0706906";
        interface-name = "wlp2s0";
        type = "wifi";
        uuid = "5e0a13a6-e5b3-4c91-8956-b2fe94bad816";
        autoconnect-priority = 100;
      };
      ipv4 = {
        method = "auto";
      };
      ipv6 = {
        addr-gen-mode = "default";
        method = "auto";
      };
      proxy = { };
      wifi = {
        mode = "infrastructure";
        ssid = "Telenet0706906";
      };
      wifi-security = {
        auth-alg = "open";
        key-mgmt = "wpa-psk";
        psk = "$HOME_WIFI_2_PASSWORD";
      };
    };
    "WiFi-2.4-908E" = {
      connection = {
        id = "WiFi-2.4-908E";
        permissions = "user:armand:;";
        timestamp = "1768842962";
        type = "wifi";
        uuid = "b18e9274-53aa-48ae-a7bc-ea9c25ed8c39";
        autoconnect-priority = 50;
      };
      ipv4 = {
        method = "auto";
      };
      ipv6 = {
        addr-gen-mode = "stable-privacy";
        method = "auto";
      };
      proxy = { };
      wifi = {
        mode = "infrastructure";
        ssid = "WiFi-2.4-908E";
      };
      wifi-security = {
        auth-alg = "open";
        key-mgmt = "wpa-psk";
        psk = "$HOME_WIFI_1_PASSWORD";
      };
    };
  };

  programs.niri = {
    enable = true;
    package = pkgs.niri;
  };

  services.tlp.enable = true;

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-user-session --cmd niri-session";
        user = "greeter";
      };
    };
  };

  virtualisation.docker = {
    enable = true;

    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  services.udisks2.enable = true;

  time.timeZone = "Europe/Brussels";

  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "nl_BE.UTF-8";
    LC_IDENTIFICATION = "nl_BE.UTF-8";
    LC_MEASUREMENT = "nl_BE.UTF-8";
    LC_MONETARY = "nl_BE.UTF-8";
    LC_NAME = "nl_BE.UTF-8";
    LC_NUMERIC = "nl_BE.UTF-8";
    LC_PAPER = "nl_BE.UTF-8";
    LC_TELEPHONE = "nl_BE.UTF-8";
    LC_TIME = "nl_BE.UTF-8";
  };

  services.xserver = {
    enable = true;
    desktopManager.xterm.enable = false;
    excludePackages = with pkgs; [
       xterm
    ];    
  };

  console.keyMap = "be-latin1";

  services.printing.enable = true;

  hardware.graphics.enable = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = false;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  stylix = {
    enable = true;
    # autoEnable = false;
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/ocean.yaml";
    targets.qt.enable = false;
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    GTK_USE_PORTAL = "1";
  };
  environment.pathsToLink = [ "/share/xdg-desktop-portal" "/share/applications" ];

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
      (xdg-desktop-portal-termfilechooser.overrideAttrs (old: {
          postInstall = (old.postInstall or "") + ''
            substituteInPlace $out/share/xdg-desktop-portal/portals/termfilechooser.portal \
              --replace "UseIn=" "UseIn=niri;"
          '';
        }))
    ];
    configPackages = [ pkgs.niri ];
    config = {
      common = {
        default = [ "gtk" ];
        "org.freedesktop.impl.portal.FileChooser" = [ "termfilechooser" ];
      };
      niri = {
        default = [ "gtk" ];
        "org.freedesktop.impl.portal.ScreenCast" = [ "hyprland" ];
        "org.freedesktop.impl.portal.Screenshot" = [ "hyprland" ];
        "org.freedesktop.impl.portal.FileChooser" = [ "termfilechooser" ];
      };
    };
  };

  # Helps portals 'find' each other and the compositor
  # services.dbus.enable = true;

  users.users.armand = {
    isNormalUser = true;
    description = "Armand";
    extraGroups = [
      "networkmanager"
      "input"
      "wheel"
      "inp.t"
      "docker"
      "video"
    ];
    hashedPasswordFile = config.sops.secrets.user_creds.path;
    shell = pkgs.nushell;
  };

  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 3d";
    persistent = true;
  };

  nix.extraOptions = ''
    min-free = ${toString (5 * 1024 * 1024 * 1024)}   # trigger GC at 5GB free
    max-free = ${toString (10 * 1024 * 1024 * 1024)}  # free up until 10GB available
  '';

  nixpkgs.config.allowBroken = false;

  nixpkgs.overlays = [
    (final: prev: {
      upower = prev.upower.overrideAttrs (old: {
        doCheck = false;
      });

    rucola = final.callPackage ({ rustPlatform, fetchFromGitHub, pkg-config, oniguruma, openssl, lib }:
      rustPlatform.buildRustPackage {
        pname = "rucola";
        version = "0.8.2";

        src = fetchFromGitHub {
          owner = "Linus-Mussmaecher";
          repo = "rucola";
          rev = "bb9ea817720e0106f3f58cda34b23a781fce51f6";
          hash = "sha256-Lg/JzB+FFPaIfue4Vwn1X4WNHaK3FSZYHsxy+ZQpbPs=";
        };

        cargoHash = "sha256-4hdG8jBD7zSG0g4H1qfNVNq4ngwRstYeum+eix41W3E=";

        nativeBuildInputs = [ pkg-config ];
        buildInputs = [ oniguruma openssl ];

        env.RUSTONIG_SYSTEM_LIBONIG = true;

        # Fails on Darwin
        checkFlags = [
          "--skip=io::file_tracker::tests::test_watcher_rename"
        ];

        meta = {
          description = "Terminal-based markdown note manager";
          homepage = "https://github.com/Linus-Mussmaecher/rucola";
          license = lib.licenses.gpl3Plus;
          mainProgram = "rucola";
          platforms = lib.platforms.linux ++ lib.platforms.darwin;
        };
      }) {};
    })
  ];

  system.autoUpgrade = {
    enable = true;
    flake = inputs.self.outPath;
    flags = [
      "--commit-lock-file"
    ];
    dates = "weekly";
  };

  nix.settings.extra-experimental-features = [
    "nix-command"
    "flakes"
  ];

  nix.optimise.automatic = true;
  nix.settings = {
    download-buffer-size = 524288000;
    auto-optimise-store = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
