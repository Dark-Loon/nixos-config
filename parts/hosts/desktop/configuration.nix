{
  config,
  pkgs,
  lib,
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

  # Bootloader.
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.useOSProber = true;
  boot.loader.grub.default = "saved";

  networking.hostName = "desktop"; # Define your hostname.
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

  hardware.graphics.enable = true;

  programs.niri = {
    enable = true;
    package = pkgs.niri;
  };

  programs.firefox.enable = true;

  # Display manager (login screen)
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-user-session --cmd niri-session";
        user = "greeter";
      };
    };
  };

  # Set your time zone.
  time.timeZone = "Europe/Brussels";

  # Select internationalisation properties.
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

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Configure console keymap
  console.keyMap = "be-latin1";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Set default editor
  environment.variables.EDITOR = "hx";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.armand = {
    isNormalUser = true;
    description = "Armand";
    extraGroups = [
      "networkmanager"
      "input"
      "wheel"
      "inp.t"
    ];
    hashedPasswordFile = config.sops.secrets.user_creds.path;
  };

  # Automatic garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # Enable experimental features
  nix.settings.extra-experimental-features = [
    "nix-command"
    "flakes"
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
