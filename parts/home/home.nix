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
        let dir = if ($start_path | path type) == "dir" {
          $start_path
        } else {
          $start_path | path dirname
        }
        cd $dir

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

  services.mpd = {
    enable = true;
    musicDirectory = "${config.home.homeDirectory}/Music";
    dataDir = "${config.home.homeDirectory}/.local/share/mpd";

    extraConfig = ''
      audio_output {
        type "pipewire"
        name "PipeWire Output"
      }
    '';
  };

  home.packages = with pkgs; [
    # Browsing
    # tor-browser # Privacy-focused browser routing traffic through the Tor network
    # mullvad # Mullvad VPN command-line client tools

    # File management
    nemo
    rucola # Terminal-based markdown note manager
    file
    xdg-utils
    typst
    watchexec
    glow
    yaziChooser
    libreoffice

    # Niri essentials
    swaybg # Wallpaper
    swayimg # Image viewer
    wl-clipboard # Clipboard utilities (wl-copy, wl-paste)
    grim # Screenshot tool
    slurp # Region selector for screenshots
    wlogout

    # Media
    mpc
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
    aider-chat-with-playwright
    azure-cli
    # claude-code # Agentic coding tool

    # Misc
    vhs
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
    settings = {
      user.name = "Dark_Loon";
      user.email = "armandgaeln@gmail.com";
      user.signingkey = "${config.home.homeDirectory}/.ssh/id_ed25519";
      alias = {
        co = "checkout";
        st = "status";
      };

      gpg.format = "ssh";
      gpg.ssh.allowedSignersFile = "${config.home.homeDirectory}/.config/git/allowed_signers";
      commit.gpgsign = true;
      tag.gpgsign = true;
      core.autocrlf = "input";
      push.autoSetupRemote = true;
      rerere.enabled = true;
      diff.algorithm = "histogram";
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
        identityFile = "${config.home.homeDirectory}/.ssh/id_ed25519";
        identitiesOnly = true;
      };
      "gitlab.com" = {
        user = "git";
        identityFile = "${config.home.homeDirectory}/.ssh/id_ed25519";
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
      StartLimitIntervalSec = 60;
      StartLimitBurst = 10;
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

    ".config/git/allowed_signers".text = ''
      armandgaeln@gmail.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEx7GhOM7YaG9DP5APm77KqFr7hwojWMxnNKoIYRnYXc
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

  xdg.configFile."rmpc/themes/catppuccin_macchiato.ron".text = ''
        #![enable(implicit_some)]
        #![enable(unwrap_newtypes)]
        #![enable(unwrap_variant_newtypes)]
        (
            default_album_art_path: None,
            format_tag_separator: " | ",
            browser_column_widths: [20, 38, 42],
            background_color: "#24273a",
            text_color: "#cad3f5",
            header_background_color: "#1e2030",
            modal_background_color: "#1e2030",
            modal_backdrop: false,
            preview_label_style: (fg: "#eed49f"),
            preview_metadata_group_style: (fg: "#eed49f", modifiers: "Bold"),
            highlighted_item_style: (fg: "#c6a0f6", modifiers: "Bold"),
            current_item_style: (fg: "#24273a", bg: "#8aadf4", modifiers: "Bold"),
            borders_style: (fg: "#494d64"),
            highlight_border_style: (fg: "#8aadf4"),
            symbols: (
                song: "S",
                dir: "D",
                playlist: "P",
                marker: "M",
                ellipsis: "...",
                song_style: None,
                dir_style: None,
                playlist_style: None,
            ),
            level_styles: (
                info: (fg: "#8aadf4", bg: "#24273a"),
                warn: (fg: "#eed49f", bg: "#24273a"),
                error: (fg: "#ed8796", bg: "#24273a"),
                debug: (fg: "#a6da95", bg: "#24273a"),
                trace: (fg: "#c6a0f6", bg: "#24273a"),
            ),
            progress_bar: (
                symbols: ["█", "█", "█", " ", "█"],
                track_style: (fg: "#363a4f"),
                elapsed_style: (fg: "#8aadf4"),
                thumb_style: (fg: "#b7bdf8"),
                use_track_when_empty: true,
            ),
            scrollbar: (
                symbols: ["│", "█", "▲", "▼"],
                track_style: (fg: "#363a4f"),
                ends_style: (fg: "#494d64"),
                thumb_style: (fg: "#8aadf4"),
            ),
            tab_bar: (
                active_style: (fg: "#24273a", bg: "#8aadf4", modifiers: "Bold"),
                inactive_style: (fg: "#a5adcb", bg: "#1e2030"),
            ),
            lyrics: (
                timestamp: false
            ),
            browser_song_format: [
                (
                    kind: Group([
                        (kind: Property(Track)),
                        (kind: Text(" ")),
                    ])
                ),
                (
                    kind: Group([
                        (kind: Property(Artist)),
                        (kind: Text(" - ")),
                        (kind: Property(Title)),
                    ]),
                    default: (kind: Property(Filename))
                ),
            ],
            song_table_format: [
                (
                    prop: (kind: Property(Artist),
                        default: (kind: Text("Unknown"))
                    ),
                    label_prop: (kind: Text("Artist")),
                    width: "20%",
                ),
                (
                    prop: (kind: Property(Title),
                        default: (kind: Text("Unknown"))
                    ),
                    label_prop: (kind: Text("Title")),
                    width: "35%",
                ),
                (
                    prop: (kind: Property(Album), style: (fg: "#b8c0e0"),
                        default: (kind: Text("Unknown Album"), style: (fg: "#b8c0e0"))
                    ),
                    label_prop: (kind: Text("Album")),
                    width: "30%",
                ),
                (
                    prop: (kind: Property(Duration),
                        default: (kind: Text("-"))
                    ),
                    label_prop: (kind: Text("Duration")),
                    width: "15%",
                    alignment: Right,
                ),
            ],
            layout: Split(
                direction: Vertical,
                panes: [
                    (
                        size: "4",
                        pane: Split(
                            direction: Horizontal,
                            panes: [
                                (
                                    size: "35",
                                    borders: "LEFT | TOP | BOTTOM",
                                    border_symbols: Inherited(parent: Rounded, bottom_left: "├"),
                                    pane: Component("header_left")
                                ),
                                (
                                    size: "100%",
                                    borders: "ALL",
                                    border_symbols: Inherited(parent: Rounded, top_left: "┬", top_right: "┬", bottom_left: "┴", bottom_right: "┴"),
                                    pane: Component("header_center")
                                ),
                                (
                                    size: "35",
                                    borders: "RIGHT | TOP | BOTTOM",
                                    border_symbols: Inherited(parent: Rounded, bottom_right: "┤"),
                                    pane: Component("header_right")
                                ),
                            ]
                        )
                    ),
                    (
                        pane: Pane(Tabs),
                        borders: "RIGHT | LEFT | BOTTOM",
                        border_symbols: Rounded,
                        size: "2",
                    ),
                    (
                        pane: Pane(TabContent),
                        size: "100%",
                    ),
                    (
                        size: "3",
                        pane: Split(
                            direction: Horizontal,
                            panes: [
                                (
                                    size: "12",
                                    borders: "ALL",
                                    border_symbols: Inherited(parent: Rounded, top_right: "┬", bottom_right: "┴"),
                                    pane: Component("input_mode")
                                ),
                                (
                                    size: "100%",
                                    borders: "TOP | BOTTOM | RIGHT",
                                    border_symbols: Rounded,
                                    border_title: [(kind: Text(" ")), (kind: Property(Status(QueueLength()))), (kind: Text(" songs / ")), (kind: Property(Status(QueueTimeTotal()))), (kind: Text(" total time "))],
                                    border_title_alignment: Right,
                                    pane: Component("progress_bar"),
                                ),
                            ]
                        ),
                    ),
                ],
            ),
            components: {
                "state": Pane(Property(
                    content: [
                        (kind: Text("["), style: (fg: "#eed49f", modifiers: "Bold")),
                        (kind: Property(Status(StateV2( ))), style: (fg: "#eed49f", modifiers: "Bold")),
                        (kind: Text("]"), style: (fg: "#eed49f", modifiers: "Bold")),
                    ], align: Left,
                )),
                "title": Pane(Property(
                    content: [
                        (kind: Property(Song(Title)), style: (modifiers: "Bold"),
                            default: (kind: Text("No Song"), style: (modifiers: "Bold"))),
                    ], align: Center, scroll_speed: 1
                )),
                "volume": Split(
                    direction: Horizontal,
                    panes: [
                        (size: "1", pane: Pane(Property(content: [(kind: Text(""))]))),
                        (size: "100%", pane: Pane(Volume(kind: Slider(symbols: (filled: "─", thumb: "●", track: "─"))))),
                        (size: "3", pane: Pane(Property(content: [(kind: Property(Status(Volume)), style: (fg: "#8aadf4"))], align: Right))),
                        (size: "2", pane: Pane(Property(content: [(kind: Text("%"), style: (fg: "#8aadf4"))]))),
                    ]
                ),
                "elapsed_and_bitrate": Pane(Property(
                    content: [
                        (kind: Property(Status(Elapsed))),
                        (kind: Text(" / ")),
                        (kind: Property(Status(Duration))),
                        (kind: Group([
                            (kind: Text(" (")),
                            (kind: Property(Status(Bitrate))),
                            (kind: Text(" kbps)")),
                        ])),
                    ],
                    align: Left,
                )),
                "artist_and_album": Pane(Property(
                    content: [
                        (kind: Property(Song(Artist)), style: (fg: "#eed49f", modifiers: "Bold"),
                            default: (kind: Text("Unknown"), style: (fg: "#eed49f", modifiers: "Bold"))),
                        (kind: Text(" - ")),
                        (kind: Property(Song(Album)), default: (kind: Text("Unknown Album"))),
                    ], align: Center, scroll_speed: 1
                )),
                "states": Split(
                    direction: Horizontal,
                    panes: [
                        (
                            size: "1",
                            pane: Pane(Empty())
                        ),
                        (
                            size: "100%",
                            pane: Pane(Property(content: [(kind: Property(Status(InputBuffer())), style: (fg: "#8aadf4"), align: Left)]))
                        ),
                        (
                            size: "6",
                            pane: Pane(Property(content: [
                                (kind: Text("["), style: (fg: "#8aadf4", modifiers: "Bold")),
                                (kind: Property(Status(RepeatV2(
                                    on_label: "z",
                                    off_label: "z",
                                    on_style: (fg: "#eed49f", modifiers: "Bold"),
                                    off_style: (fg: "#494d64", modifiers: "Dim"),
                                )))),
                                (kind: Property(Status(RandomV2(
                                    on_label: "x",
                                    off_label: "x",
                                    on_style: (fg: "#eed49f", modifiers: "Bold"),
                                    off_style: (fg: "#494d64", modifiers: "Dim"),
                                )))),
                                (kind: Property(Status(ConsumeV2(
                                    on_label: "c",
                                    off_label: "c",
                                    oneshot_label: "c",
                                    on_style: (fg: "#eed49f", modifiers: "Bold"),
                                    off_style: (fg: "#494d64", modifiers: "Dim"),
                                    oneshot_style: (fg: "#ed8796", modifiers: "Dim"),
                                )))),
                                (kind: Property(Status(SingleV2(
                                    on_label: "v",
                                    off_label: "v",
                                    oneshot_label: "v",
                                    on_style: (fg: "#eed49f", modifiers: "Bold"),
                                    off_style: (fg: "#494d64", modifiers: "Dim"),
                                    oneshot_style: (fg: "#ed8796", modifiers: "Bold"),
                                )))),
                                (kind: Text("]"), style: (fg: "#8aadf4", modifiers: "Bold")),
                                ],
                                align: Right
                            ))
                        ),
                    ]
                ),
                "input_mode": Pane(Property(
                    content: [
                        (kind: Transform(Replace(content: (kind: Property(Status(InputMode()))), replacements: [
                            (match: "Normal", replace: (kind: Text(" NORMAL "), style: (fg: "#24273a", bg: "#8aadf4"))),
                            (match: "Insert", replace: (kind: Text(" INSERT "), style: (fg: "#24273a", bg: "#a6da95"))),
                        ])))
                    ], align: Center
                )),
                "header_left": Split(
                    direction: Vertical,
                    panes: [
                        (size: "1", pane: Component("state")),
                        (size: "1", pane: Component("elapsed_and_bitrate")),
                    ]
                ),
                "header_center": Split(
                    direction: Vertical,
                    panes: [
                        (size: "1", pane: Component("title")),
                        (size: "1", pane: Component("artist_and_album")),
                    ]
                ),
                "header_right": Split(
                    direction: Vertical,
                    panes: [
                        (size: "1", pane: Component("volume")),
                        (size: "1", pane: Component("states")),
                    ]
                ),
                "progress_bar": Split(
                    direction: Horizontal,
                    panes: [
                        (
                            size: "1",
                            pane: Pane(Empty())
                        ),
                        (
                            size: "100%",
                            pane: Pane(ProgressBar)
                        ),
                        (
                            size: "1",
                            pane: Pane(Empty())
                        ),
                    ]
                )
            },
        )
    '';

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
    secondary_viewer = ["rucola-glow", "%p"]
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

  xdg = {
    desktopEntries = {
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

      "rmpc" = {
        name = "Rmpc";
        exec = "rmpc";
        noDisplay = true;
      };

      "notes-open" = {
        name = "Notes Open";
        exec = "notes-open %u";
        noDisplay = true;
        mimeType = [ "x-scheme-handler/notes" ];
      };
    };
    mimeApps = {
      enable = true;
      defaultApplications = {
        "application/pdf" = "org.pwmt.zathura.desktop";
        "text/html" = "firefox.desktop";
        "x-scheme-handler/http" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
        "x-scheme-handler/about" = "firefox.desktop";
        "x-scheme-handler/unknown" = "firefox.desktop";
        "x-scheme-handler/notes" = "notes-open.desktop";
        "text/plain" = "Helix.desktop";
        "application/x-nuscript" = "Helix.desktop";
        "application/octet-stream" = "Helix.desktop";
      };
    };
  };
}
