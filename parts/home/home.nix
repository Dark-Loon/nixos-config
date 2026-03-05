{ pkgs, ... }:
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
  services.udiskie.enable = true;

  home.packages = with pkgs; [
    # Browsing
    # tor-browser # Privacy-focused browser routing traffic through the Tor network
    # mullvad # Mullvad VPN command-line client tools

    # File management
    nemo
    rucola # Terminal-based markdown note manager
    file
    xdg-utils
    glow
    android-tools

    # Niri essentials
    swaybg # Wallpaper
    swayimg # Image viewer
    wl-clipboard # Clipboard utilities (wl-copy, wl-paste)
    grim # Screenshot tool
    slurp # Region selector for screenshots
    wlogout

    # Media
    blueberry
    pavucontrol
    obs-studio
    obs-cmd
    yt-dlp # Command-line tool to download videos from YouTube.com and other sites (youtube-dl fork)
    vlc # Media Player
    # dim # Self-hosted media manager
    # qbittorrent # OpenSource Qt Bittorrent client

    # Coding
    zellij # Terminal workspace with batteries included
    curl
    # claude-code # Agentic coding tool

    # Misc
    nixd
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

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
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

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "application/pdf" = "org.pwmt.zathura.desktop";
      "text/html" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "x-scheme-handler/about" = "firefox.desktop";
      "x-scheme-handler/unknown" = "firefox.desktop";
      "text/plain" = "helix.desktop";
      "application/x-nuscript" = "helix.desktop";
      "application/octet-stream" = "helix.desktop";
    };
  };

  xdg.desktopEntries.helix = {
    name = "Helix";
    genericName = "Text Editor";
    comment = "Fast modal text editor";
    exec = "foot hx %F";
    terminal = false;
    icon = "helix";
    categories = [
      "Utility"
      "TextEditor"
    ];
    mimeType = [
      "text/plain"
      "application/x-nuscript"
      "application/octet-stream"
    ];
  };
}
