{ pkgs, config, lib, ... }:
let
  yaziChooser = pkgs.writeTextFile {
    name = "yazi-chooser";
    executable = true;
    destination = "/bin/yazi-chooser";
    text = ''
      #!${pkgs.nushell}/bin/nu

      def find-term [] {
        let candidates = [
          "${pkgs.foot}/bin/foot"
          "${pkgs.ghostty}/bin/ghostty"
        ]
        $candidates | where { path exists } | get 0?
      }

      def main [multiple: int, allow_dirs: int, save: int, start_path: string, output: string, ...rest: string] {
        cd $start_path

        touch $output
        
        let term = find-term
        if $term == null {
          error make { msg: "No terminal emulator found in candidates" }
        }
        match ($term | path basename) {
          "foot"      => { ^$term --app-id "yazi-chooser" -- ${pkgs.yazi}/bin/yazi --chooser-file $output }
          "ghostty"   => { ^$term --class "yazi-chooser" -- ${pkgs.yazi}/bin/yazi --chooser-file $output }
          _           => { ^$term "yazi-chooser" -- ${pkgs.yazi}/bin/yazi --chooser-file $output }
        }
      }
    '';
  };

  bluemanSizes = [ "16x16" "22x22" "24x24" "32x32" "48x48" ];
  bluemanIcons = {
    "status" = [ "blueman-active" "blueman-disabled" "blueman-tray" "blueman"];
    "apps" = [ "blueman" ];
  };
in
{
  imports = [
    ./programs
    ../modules
  ];

  home.username = "armand";
  home.homeDirectory = "/home/armand";
  home.stateVersion = "26.05";

  # Assist with reloading and restarting systemd units
  systemd.user.startServices = "sd-switch";

  programs.swaylock.enable = true;
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
    pandoc
    watchexec
    glow
    yaziChooser
    ssh-to-age

    # Niri essentials
    swaybg # Wallpaper
    swayimg # Image viewer
    wl-clipboard # Clipboard utilities (wl-copy, wl-paste)
    grim # Screenshot tool
    slurp # Region selector for screenshots
    wlogout

    # Media
    pavucontrol
    obs-studio
    obs-cmd
    yt-dlp # Command-line tool to download videos from YouTube.com and other sites (youtube-dl fork)
    vlc # Media Player
    # dim # Self-hosted media manager
    # qbittorrent # OpenSource Qt Bittorrent client

    # Coding
    aider-chat-with-playwright
    zellij # Terminal workspace with batteries included
    curl
    azure-cli
    # claude-code # Agentic coding tool

    # Misc
    brightnessctl
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

  programs.ssh = {
    matchBlocks = {
      "*" = {
        addKeysToAgent = "yes";
      };
      "gitlab" = {
        hostname = "gitlab.com";
        user = "git";
        identityFile = "~/.ssh/id_ed25519";
        identitiesOnly = true;
      };
      "gitlab.com" = {
        user = "git";
        identityFile = "~/.ssh/id_ed25519";
        identitiesOnly = true;
      };            
    };
  };
  
  systemd.user.services.set-default-volume = {
    Unit = {
      Description = "Set default sink volume on login";
      After = [ "pipewire-pulse.service" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ 50%";
      RemainAfterExit = true;
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  systemd.user.services.blueman-applet = {
    Unit = {
      Description = "Blueman applet";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.blueman}/bin/blueman-applet";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  systemd.user.services.firefox-bookmark-sync = {
    Unit = {
      Description = "Export Firefox bookmarks to dotfiles";
      After = [ "graphical-session.target" ];
      StartLimitIntervalSec = 120;
      StartLimitBurst = 3;
    };
    Service = {
      Type = "oneshot";
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 10";
      ExecStart = "${pkgs.nushell}/bin/nu %h/dotfiles/parts/home/programs/firefox/scripts/ff-bookmarks-live.nu --out %h/dotfiles/parts/home/programs/firefox/bookmarks.json";
      Environment = "HOME=%h";
    };
  };

  systemd.user.paths.firefox-bookmark-sync = {
    Unit.Description = "Watch Firefox places.sqlite-wal for changes";
    Path = {
      PathModified = "%h/.mozilla/firefox/profile_0/places.sqlite-wal";
      Unit = "firefox-bookmark-sync.service";
    };
    Install.WantedBy = [ "default.target" ];
  };

  systemd.user.timers.firefox-bookmark-sync = {
    Unit.Description = "Periodically sync Firefox bookmarks";
    Timer = {
      OnCalendar = "*:0/15";   # every 15 minutes
      Persistent = true;
      Unit = "firefox-bookmark-sync.service";
    };
    Install.WantedBy = [ "timers.target" ];
  };

  home.file = 
    lib.listToAttrs (lib.flatten (map (size:
      lib.mapAttrsToList (cat: icons:
        lib.flatten (map (icon:
          let path = "${pkgs.blueman}/share/icons/hicolor/${size}/${cat}/${icon}.png";
          in lib.optional (builtins.pathExists path) {
            name = ".local/share/icons/PapirosBlueman/${size}/${cat}/${icon}.png";
            value.source = path;
          }
        ) icons)
      ) bluemanIcons
    ) bluemanSizes))
    // {
    ".local/share/icons/PapirosBlueman/index.theme".text = ''
      [Icon Theme]
      Name=PapirosBlueman
      Comment=Papirus-Dark with blueman overrides
      Inherits=Papirus-Dark
    '';

    ".config/xdg-desktop-portal-termfilechooser/config".text = ''
      [filechooser]
      cmd = ${yaziChooser}/bin/yazi-chooser
      default_dir = $HOME
    '';
    }
  ;

  gtk.iconTheme = {
    package = pkgs.papirus-icon-theme;
    name = "PapirosBlueman";
  };

  # In home-manager or system config
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  stylix = {
    targets = {
      firefox.enable = false;
      helix.enable = false;            
      mako.enable = false;
      niri.enable = false;      
      qt.enable = false;            
      waybar.enable = false;      
    };
    fonts.sizes = {
      applications = 10;
      desktop = 10;
    };
  };
  
  xdg.configFile."yazi/plugins/glow.yazi/main.lua".source = ./programs/yazi/glow.lua;

  xdg.configFile."rucola/config.toml".text = ''
    file_types = ["markdown"]
    default_extension = "md"
    cache_index = false
    theme = "default_dark"
    stats_show = "Relevant"
    viewer = [
        "firefox",
        "-P",
        "Notes",
        "%p",
    ]
    secondary_viewer = ["glow", "%p"]
    css = "${config.home.homeDirectory}/.config/rucola/default_dark.css"
    katex = true

    [math_replacements]
    '\field' = '\mathbb'
  '';

  xdg.configFile."rucola/default_dark.css".text = ''
    body{
      max-width: 60%;
      margin: auto;
      background: #112c37;
    }

    p{
      font-size: 14px;
      color: #e2e8f3;
    }
    li{
      font-size: 14px;
      color: #e2e8f3;
    }

    h1{
      color: #6b84bd;
      font-size: 30px;
      font-family: "Times New Roman";
      font-style: italic;
    }

    h2{
      color: #6b84bd;
      font-size: 20px;
      font-family: "Times New Roman";
    }

    h3{
      color: #405b8c;
      font-size: 18px;
      font-family: "Times New Roman";
    }

    h4{
      color: #9bcfc8;
      font-size: 16px;
      font-family: "Times New Roman";
      font-style: italic;
    }

    a{  
      color: #6b84bd;
      text-decoration: none;
    }

    a:hover{
      color: #9bcfc8;
      text-decoration: underline;
    }
  '';

  xdg.desktopEntries = {
    "blueman-adapters" = {
      name = "Bluetooth Adapters";
      exec = "blueman-adapters";
      icon = "blueman";
      categories = [ "Settings" ];
    };

    "yazi" = {
      name = "Yazi";
      exec = "foot -- yazi %F";
      icon = "system-file-manager";
      categories = [ "System" "FileManager" ];
    };

    "Helix" = {
      name = "Helix";
      exec = "hx %F";
      icon = "helix";
      mimeType = [ "text/plain" "application/x-nuscript" "application/octet-stream" ];
      noDisplay = true;
    };

    "footclient" = {
      name = "Foot Client";
      exec = "footclient";
      noDisplay = true;
    };

    "foot-server" = {
      name = "Foot Server";
      exec = "foot --server";
      noDisplay = true;
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
      "text/plain" = "Helix.desktop";
      "application/x-nuscript" = "Helix.desktop";
      "application/octet-stream" = "Helix.desktop";
    };
  };
}
