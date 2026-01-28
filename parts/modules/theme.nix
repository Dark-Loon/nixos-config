{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.myConfig.wallpaper;

  wallpaperScript = pkgs.writeShellScript "wallpaper-cycler" ''
    IMAGE_DIR="${cfg.imageDir}"

    cd "$IMAGE_DIR"
    while true; do
        PID=$(pidof swaybg)
        IMAGE_NUM=$(printf "%03d" $((($(date -u +%s) / 5400) % 16 + 1)))

        if [ -f "./$IMAGE_NUM.png" ]; then
            ${pkgs.swaybg}/bin/swaybg -i "$IMAGE_DIR/$IMAGE_NUM.png" -m fill &
            sleep 1
            kill $PID 2>/dev/null
        fi
        sleep 5399
    done
  '';
in
{
  options.myConfig.wallpaper = {
    enable = lib.mkEnableOption "time-based wallpaper cycling";

    imageDir = lib.mkOption {
      type = lib.types.path;
      default = ./img;
      description = "Directory containing equidistant images (001.png - 016.png)";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.swaybg ];

    systemd.user.services.wallpaper-cycler = {
      Unit = {
        Description = "Time-based wallpaper cycling";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        ExecStart = "${wallpaperScript}";
        Restart = "on-failure";
      };

      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
