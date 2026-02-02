{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.myConfig.wallpaper;

  wallpaperScript = pkgs.writeScriptBin "wallpaper-cycler" ''
    #!${pkgs.nushell}/bin/nu

    def main [
      --interval: duration = 1.5hr
      --num_images: int = 16
    ] {
      let image_dir = "${cfg.imageDir}"

      cd $image_dir
      loop {
        let pid = (^pidof swaybg | complete | get stdout | str trim)

        let current_time = (date now | format date "%s" | into int)
        let interval_seconds = ($interval / 1sec) # Convert duration from nanoseconds to seconds
        let division_result = ($current_time / $interval_seconds)
        let mod_result = (($division_result | math floor) mod $num_images)
        let image_num = (
          ($mod_result + 1)
          | into string
          | fill --alignment right --character "0" --width 3
        )

        #print $"Debug: current_time=($current_time), interval=($interval_seconds), division=($division_result), mod=($mod_result), image_num=($image_num)"

        let image_path = $"($image_dir)/($image_num).png"

        if ($image_path | path exists) {
          do { ^${pkgs.swaybg}/bin/swaybg -i $image_path -m fill } | ignore
          sleep 1sec
          if ($pid != "") {
            try { ^kill $pid } catch { }
          }
        } else {
          print $"Image not found: ($image_path)"
        }

        sleep ($interval - 1sec)
      }
    }
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
    interval = lib.mkOption {
      type = lib.types.str;
      default = "1.5hr";
      description = "How long to show each wallpaper";
    };
    numImages = lib.mkOption {
      type = lib.types.int;
      default = 16;
      description = "Number of images to cycle through";
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
        ExecStart = "${wallpaperScript}/bin/wallpaper-cycler --interval ${cfg.interval} --num_images ${toString cfg.numImages}";
        Restart = "on-failure";
      };

      Install.WantedBy = [ "graphical-session.target" ];
    };

    systemd.user.services.wallpaper-cycler-resume = {
      Unit = {
        Description = "Update wallpaper after resume";
        After = [
          "suspend.target"
          "hibernate.target"
          "hybrid-sleep.target"
        ];
      };

      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.systemd}/bin/systemctl --user restart wallpaper-cycler.service";
      };

      Install.WantedBy = [
        "suspend.target"
        "hibernate.target"
        "hybrid-sleep.target"
      ];
    };
  };
}
