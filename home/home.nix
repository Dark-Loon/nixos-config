{ config, pkgs, ... }:
{
  imports = [
    ./programs
    ../modules
  ];

  home.username = "armand";
  home.homeDirectory = "/home/armand";
  home.stateVersion = "25.05";

  systemd.user.startServices = "sd-switch";

  programs.fuzzel.enable = true;
  programs.swaylock.enable = true;
  programs.waybar.enable = true;
  services.mako.enable = true;
  services.swayidle.enable = true;
  services.polkit-gnome.enable = true;

  home.packages = with pkgs; [
    # Browsing
    tor-browser # Privacy-focused browser routing traffic through the Tor network
    # mullvad # Mullvad VPN command-line client tools

    # File management
    nemo
    rucola # Terminal-based markdown note manager
    zoxide # Fast cd command that learns your habits
    file
    xdg-utils
    glow
    typst
    typstyle

    # Niri essentials
    swaybg # Wallpaper
    swayimg # Image viewer
    zathura # PDF viewer
    wl-clipboard # Clipboard utilities (wl-copy, wl-paste)
    grim # Screenshot tool
    slurp # Region selector for screenshots
    wlogout

    # Media
    blueberry
    pavucontrol
    obs-studio
    yt-dlp # Command-line tool to download videos from YouTube.com and other sites (youtube-dl fork)
    # vlc # Media Player
    # dim # Self-hosted media manager
    # qbittorrent # OpenSource Qt Bittorrent client

    # Coding
    zellij # Terminal workspace with batteries included
    curl
    # claude-code # Agentic coding tool

    # Misc
    cmatrix
    htop
    # bitwarden-cli # Secure and free password manager for all of your devices
    # wiki-tui # Simple and easy to use Wikipedia Text User Interface
    # hledger # CLI for the hledger accounting system
  ];

  myConfig.wallpaper = {
    enable = true;
    imageDir = ../modules/img;
  };

  programs.git = {
    enable = true;
    lfs.enable = true;
    settings.user.name = "Dark_Loon";
    settings.user.email = "armandgaeln@gmail.com";
    settings.alias = {
      co = "checkout";
      st = "status";
    };
  };

  programs.helix = {
    enable = true;
    settings = {
      theme = "autumn_night_transparent";
      editor.cursor-shape = {
        normal = "block";
        insert = "bar";
        select = "underline";
      };
    };
    languages.language = [
      {
        name = "nix";
        auto-format = true;
        formatter.command = "${pkgs.nixfmt}/bin/nixfmt";
      }
    ];
    themes = {
      autumn_night_transparent = {
        "inherits" = "autumn_night";
        "ui.background" = { };
      };
    };
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "application/pdf" = "org.pwmt.zathura.desktop";
    };
  };

  xdg.desktopEntries.ghostty = {
    name = "Ghostty";
    exec = "ghostty";
    terminal = false;
    categories = [
      "System"
      "TerminalEmulator"
    ];
    icon = "${pkgs.ghostty}/share/icons/hicolor/128x128/apps/com.mitchellh.ghostty.png";
  };
}
