{
  pkgs,
  lib,
  config,
  ...
}:
{
  programs.niri.settings = {
    input = {
      keyboard = {
        xkb = {
          layout = "be_custom";
        };
        numlock = true;
      };
    };
    layout = {
      # Set gaps around windows in logical pixels.
      gaps = 16;

      # When to center a column when changing focus, options are:
      # - "never", default behavior, focusing an off-screen column will keep at the left
      #   or right edge of the screen.
      # - "always", the focused column will always be centered.
      # - "on-overflow", focusing a column will center it if it doesn't fit
      #   together with the previously focused column.
      center-focused-column = "never";

      # You can customize the widths that "switch-preset-column-width" (Mod+R) toggles between.
      preset-column-widths = [
        # Proportion sets the width as a fraction of the output width, taking gaps into account.
        # For example, you can perfectly fit four windows sized "proportion 0.25" on an output.
        # The default preset widths are 1/3, 1/2 and 2/3 of the output.
        { proportion = 0.33333; }
        { proportion = 0.5; }
        { proportion = 0.66667; }

        # Fixed sets the width in logical pixels exactly.
        # { fixed = 1920; }
      ];

      # You can also customize the heights that "switch-preset-window-height" (Mod+Shift+R) toggles between.
      # preset-window-heights = [];

      # You can change the default width of the new windows.
      default-column-width = {
        proportion = 0.5;
      };
      # If you leave the brackets empty, the windows themselves will decide their initial width.
      # default-column-width = {};

      # By default focus ring and border are rendered as a solid background rectangle
      # behind windows. That is, they will show up through semitransparent windows.
      # This is because windows using client-side decorations can have an arbitrary shape.
      #
      # If you don't like that, you should uncomment `prefer-no-csd` below.
      # Niri will draw focus ring and border *around* windows that agree to omit their
      # client-side decorations.
      #
      # Alternatively, you can override it with a window rule called
      # `draw-border-with-background`.

      # You can change how the focus ring looks.
      focus-ring = {
        # Uncomment this line to disable the focus ring.
        # off = true;

        # How many logical pixels the ring extends out from the windows.
        width = 4;

        # Colors can be set in a variety of ways:
        # - CSS named colors: "red"
        # - RGB hex: "#rgb", "#rgba", "#rrggbb", "#rrggbbaa"
        # - CSS-like notation: "rgb(255, 127, 0)", rgba(), hsl() and a few others.

        # Color of the ring on the active monitor.
        active.color = "#7FC8FF";

        # Color of the ring on inactive monitors.
        #
        # The focus ring only draws around the active window, so the only place
        # where you can see its inactive-color is on other monitors.
        inactive.color = "#505050";

        # You can also use gradients. They take precedence over solid colors.
        # Gradients are rendered the same as CSS linear-gradient(angle, from, to).
        # The angle is the same as in linear-gradient, and is optional,
        # defaulting to 180 (top-to-bottom gradient).
        # You can use any CSS linear-gradient tool on the web to set these up.
        # Changing the color space is also supported, check the wiki for more info.
        #
        # active-gradient = { from = "#80c8ff"; to = "#c7ff7f"; angle = 45; };

        # You can also color the gradient relative to the entire view
        # of the workspace, rather than relative to just the window itself.
        # To do that, set relative-to="workspace-view".
        #
        # inactive-gradient = { from = "#505050"; to = "#808080"; angle = 45; relative-to = "workspace-view"; };
      };

      # You can also add a border. It's similar to the focus ring, but always visible.
      border = {
        # The settings are the same as for the focus ring.
        # If you enable the border, you probably want to disable the focus ring.
        enable = false;

        width = 4;
        active.color = "#FFC87F";
        inactive.color = "#505050";

        # Color of the border around windows that request your attention.
        urgent.color = "#9B0000";

        # Gradients can use a few different interpolation color spaces.
        # For example, this is a pastel rainbow gradient via in="oklch longer hue".
        #
        # active-gradient = { from = "#e5989b"; to = "#ffb4a2"; angle = 45; relative-to = "workspace-view"; in = "oklch longer hue"; };

        # inactive-gradient = { from = "#505050"; to = "#808080"; angle = 45; relative-to = "workspace-view"; };
      };

      # You can enable drop shadows for windows.
      shadow = {
        # Uncomment the next line to enable shadows.
        # on = true;

        # By default, the shadow draws only around its window, and not behind it.
        # Uncomment this setting to make the shadow draw behind its window.
        #
        # Note that niri has no way of knowing about the CSD window corner
        # radius. It has to assume that windows have square corners, leading to
        # shadow artifacts inside the CSD rounded corners. This setting fixes
        # those artifacts.
        #
        # However, instead you may want to set prefer-no-csd and/or
        # geometry-corner-radius. Then, niri will know the corner radius and
        # draw the shadow correctly, without having to draw it behind the
        # window. These will also remove client-side shadows if the window
        # draws any.
        #
        # draw-behind-window = true;

        # You can change how shadows look. The values below are in logical
        # pixels and match the CSS box-shadow properties.

        # Softness controls the shadow blur radius.
        softness = 30;

        # Spread expands the shadow.
        spread = 5;

        # Offset moves the shadow relative to the window.
        offset = {
          x = 0;
          y = 5;
        };

        # You can also change the shadow color and opacity.
        color = "#0007";
      };

      # Struts shrink the area occupied by windows, similarly to layer-shell panels.
      # You can think of them as a kind of outer gaps. They are set in logical pixels.
      # Left and right struts will cause the next window to the side to always be visible.
      # Top and bottom struts will simply add outer gaps in addition to the area occupied by
      # layer-shell panels and regular gaps.
      struts = {
        # left = 64;
        # right = 64;
        # top = 64;
        # bottom = 64;
      };
    };

    hotkey-overlay = {
      # Uncomment this line to disable the "Important Hotkeys" pop-up at startup.
      skip-at-startup = true;
    };

    prefer-no-csd = true;

    screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";

    animations = {
      # Uncomment to turn off all animations.
      # off = true;

      # Slow down all animations by this factor. Values below 1 speed them up instead.
      # slowdown = 3.0;
    };

    window-rules = [
      {
        opacity = 0.95;
      }

      # Terminals slightly more transparent
      {
        matches = [ { app-id = "^(foot|ghostty)$"; } ];
        opacity = 0.90;
      }

      # Keep these fully opaque
      {
        matches = [ { app-id = "^(vlc|mpv)$"; } ];
        opacity = 1.0;
      }
      {
        matches = [
          {
            app-id = "^.*firefox$";
            title = "^Picture-in-Picture$";
          }
        ];
        open-floating = true;
        opacity = 1.0;
      }
    ];

    # Basic keybindings
    binds = {
      # Mod-Shift-/, which is usually the same as Mod-?,
      # shows a list of important hotkeys.
      "Mod+Shift+Slash".action.show-hotkey-overlay = { };

      # Suggested binds for running programs: terminal, app launcher, screen locker.
      "Mod+T" = {
        action.spawn = "ghostty";
        hotkey-overlay = {
          title = "Open a Terminal: ghostty";
        };
      };
      "Mod+D" = {
        action.spawn = "fuzzel";
        hotkey-overlay = {
          title = "Run an Application: fuzzel";
        };
      };
      "Super+Alt+L" = {
        action.spawn = "swaylock";
        hotkey-overlay = {
          title = "Lock the Screen: swaylock";
        };
      };

      # Use spawn-sh to run a shell command. Do this if you need pipes, multiple commands, etc.
      # Note: the entire command goes as a single argument. It's passed verbatim to `sh -c`.
      # For example, this is a standard bind to toggle the screen reader (orca).
      "Super+Alt+S" = {
        action.spawn-sh = "pkill orca || exec orca";
        allow-when-locked = true;
        hotkey-overlay = {
          hidden = true;
        };
      };

      # Open/close the Overview: a zoomed-out view of workspaces and windows.
      # You can also move the mouse into the top-left hot corner,
      # or do a four-finger swipe up on a touchpad.
      "Mod+O" = {
        action.toggle-overview = { };
        repeat = false;
      };

      "Mod+Q" = {
        action.close-window = { };
        repeat = false;
      };

      "Mod+Left".action.focus-column-left = { };
      "Mod+Down".action.focus-window-down = { };
      "Mod+Up".action.focus-window-up = { };
      "Mod+Right".action.focus-column-right = { };
      "Mod+H".action.focus-column-left = { };
      "Mod+J".action.focus-window-down = { };
      "Mod+K".action.focus-window-up = { };
      "Mod+L".action.focus-column-right = { };

      "Mod+Ctrl+Left".action.move-column-left = { };
      "Mod+Ctrl+Down".action.move-window-down = { };
      "Mod+Ctrl+Up".action.move-window-up = { };
      "Mod+Ctrl+Right".action.move-column-right = { };
      "Mod+Ctrl+H".action.move-column-left = { };
      "Mod+Ctrl+J".action.move-window-down = { };
      "Mod+Ctrl+K".action.move-window-up = { };
      "Mod+Ctrl+L".action.move-column-right = { };

      # Alternative commands that move across workspaces when reaching
      # the first or last window in a column.
      # "Mod+J".action.focus-window-or-workspace-down = {};
      # "Mod+K".action.focus-window-or-workspace-up = {};
      # "Mod+Ctrl+J".action.move-window-down-or-to-workspace-down = {};
      # "Mod+Ctrl+K".action.move-window-up-or-to-workspace-up = {};

      "Mod+Home".action.focus-column-first = { };
      "Mod+End".action.focus-column-last = { };
      "Mod+Ctrl+Home".action.move-column-to-first = { };
      "Mod+Ctrl+End".action.move-column-to-last = { };

      "Mod+Shift+Left".action.focus-monitor-left = { };
      "Mod+Shift+Down".action.focus-monitor-down = { };
      "Mod+Shift+Up".action.focus-monitor-up = { };
      "Mod+Shift+Right".action.focus-monitor-right = { };
      "Mod+Shift+H".action.focus-monitor-left = { };
      "Mod+Shift+J".action.focus-monitor-down = { };
      "Mod+Shift+K".action.focus-monitor-up = { };
      "Mod+Shift+L".action.focus-monitor-right = { };

      "Mod+Shift+Ctrl+Left".action.move-column-to-monitor-left = { };
      "Mod+Shift+Ctrl+Down".action.move-column-to-monitor-down = { };
      "Mod+Shift+Ctrl+Up".action.move-column-to-monitor-up = { };
      "Mod+Shift+Ctrl+Right".action.move-column-to-monitor-right = { };
      "Mod+Shift+Ctrl+H".action.move-column-to-monitor-left = { };
      "Mod+Shift+Ctrl+J".action.move-column-to-monitor-down = { };
      "Mod+Shift+Ctrl+K".action.move-column-to-monitor-up = { };
      "Mod+Shift+Ctrl+L".action.move-column-to-monitor-right = { };

      # Alternatively, there are commands to move just a single window:
      # "Mod+Shift+Ctrl+Left".action.move-window-to-monitor-left = {};
      # ...

      # And you can also move a whole workspace to another monitor:
      # "Mod+Shift+Ctrl+Left".action.move-workspace-to-monitor-left = {};
      # ...

      "Mod+Page_Down".action.focus-workspace-down = { };
      "Mod+Page_Up".action.focus-workspace-up = { };
      "Mod+U".action.focus-workspace-down = { };
      "Mod+I".action.focus-workspace-up = { };
      "Mod+Ctrl+Page_Down".action.move-column-to-workspace-down = { };
      "Mod+Ctrl+Page_Up".action.move-column-to-workspace-up = { };
      "Mod+Ctrl+U".action.move-column-to-workspace-down = { };
      "Mod+Ctrl+I".action.move-column-to-workspace-up = { };

      # Alternatively, there are commands to move just a single window:
      # "Mod+Ctrl+Page_Down".action.move-window-to-workspace-down = {};
      # ...

      "Mod+Shift+Page_Down".action.move-workspace-down = { };
      "Mod+Shift+Page_Up".action.move-workspace-up = { };
      "Mod+Shift+U".action.move-workspace-down = { };
      "Mod+Shift+I".action.move-workspace-up = { };

      # You can bind mouse wheel scroll ticks using the following syntax.
      # These binds will change direction based on the natural-scroll setting.
      #
      # To avoid scrolling through workspaces really fast, you can use
      # the cooldown-ms property. The bind will be rate-limited to this value.
      # You can set a cooldown on any bind, but it's most useful for the wheel.
      "Mod+WheelScrollDown" = {
        action.focus-workspace-down = { };
        cooldown-ms = 150;
      };
      "Mod+WheelScrollUp" = {
        action.focus-workspace-up = { };
        cooldown-ms = 150;
      };
      "Mod+Ctrl+WheelScrollDown" = {
        action.move-column-to-workspace-down = { };
        cooldown-ms = 150;
      };
      "Mod+Ctrl+WheelScrollUp" = {
        action.move-column-to-workspace-up = { };
        cooldown-ms = 150;
      };

      "Mod+WheelScrollRight".action.focus-column-right = { };
      "Mod+WheelScrollLeft".action.focus-column-left = { };
      "Mod+Ctrl+WheelScrollRight".action.move-column-right = { };
      "Mod+Ctrl+WheelScrollLeft".action.move-column-left = { };

      # Usually scrolling up and down with Shift in applications results in
      # horizontal scrolling; these binds replicate that.
      "Mod+Shift+WheelScrollDown".action.focus-column-right = { };
      "Mod+Shift+WheelScrollUp".action.focus-column-left = { };
      "Mod+Ctrl+Shift+WheelScrollDown".action.move-column-right = { };
      "Mod+Ctrl+Shift+WheelScrollUp".action.move-column-left = { };

      # Similarly, you can bind touchpad scroll "ticks".
      # Touchpad scrolling is continuous, so for these binds it is split into
      # discrete intervals.
      # These binds are also affected by touchpad's natural-scroll, so these
      # example binds are "inverted", since we have natural-scroll enabled for
      # touchpads by default.
      # "Mod+TouchpadScrollDown".action.spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.02+";
      # "Mod+TouchpadScrollUp".action.spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.02-";

      # You can refer to workspaces by index. However, keep in mind that
      # niri is a dynamic workspace system, so these commands are kind of
      # "best effort". Trying to refer to a workspace index bigger than
      # the current workspace count will instead refer to the bottommost
      # (empty) workspace.
      #
      # For example, with 2 workspaces + 1 empty, indices 3, 4, 5 and so on
      # will all refer to the 3rd workspace.
      "Mod+1".action.focus-workspace = 1;
      "Mod+2".action.focus-workspace = 2;
      "Mod+3".action.focus-workspace = 3;
      "Mod+4".action.focus-workspace = 4;
      "Mod+5".action.focus-workspace = 5;
      "Mod+6".action.focus-workspace = 6;
      "Mod+7".action.focus-workspace = 7;
      "Mod+8".action.focus-workspace = 8;
      "Mod+9".action.focus-workspace = 9;
      "Mod+Ctrl+1".action.move-column-to-workspace = 1;
      "Mod+Ctrl+2".action.move-column-to-workspace = 2;
      "Mod+Ctrl+3".action.move-column-to-workspace = 3;
      "Mod+Ctrl+4".action.move-column-to-workspace = 4;
      "Mod+Ctrl+5".action.move-column-to-workspace = 5;
      "Mod+Ctrl+6".action.move-column-to-workspace = 6;
      "Mod+Ctrl+7".action.move-column-to-workspace = 7;
      "Mod+Ctrl+8".action.move-column-to-workspace = 8;
      "Mod+Ctrl+9".action.move-column-to-workspace = 9;

      # Alternatively, there are commands to move just a single window:
      # "Mod+Ctrl+1".action.move-window-to-workspace = 1;

      # Switches focus between the current and the previous workspace.
      # "Mod+Tab".action.focus-workspace-previous = {};

      # The following binds move the focused window in and out of a column.
      # If the window is alone, they will consume it into the nearby column to the side.
      # If the window is already in a column, they will expel it out.
      "Mod+BracketLeft".action.consume-or-expel-window-left = { };
      "Mod+BracketRight".action.consume-or-expel-window-right = { };

      # Consume one window from the right to the bottom of the focused column.
      "Mod+Comma".action.consume-window-into-column = { };
      # Expel the bottom window from the focused column to the right.
      "Mod+Period".action.expel-window-from-column = { };

      "Mod+R".action.switch-preset-column-width = { };
      # Cycling through the presets in reverse order is also possible.
      # "Mod+R".action.switch-preset-column-width-back = {};
      "Mod+Shift+R".action.switch-preset-window-height = { };
      "Mod+Ctrl+R".action.reset-window-height = { };
      "Mod+F".action.maximize-column = { };
      "Mod+Shift+F".action.fullscreen-window = { };

      # Expand the focused column to space not taken up by other fully visible columns.
      # Makes the column "fill the rest of the space".
      "Mod+Ctrl+F".action.expand-column-to-available-width = { };

      "Mod+C".action.center-column = { };

      # Center all fully visible columns on screen.
      "Mod+Ctrl+C".action.center-visible-columns = { };

      # Finer width adjustments.
      # This command can also:
      # * set width in pixels: "1000"
      # * adjust width in pixels: "-5" or "+5"
      # * set width as a percentage of screen width: "25%"
      # * adjust width as a percentage of screen width: "-10%" or "+10%"
      # Pixel sizes use logical, or scaled, pixels. I.e. on an output with scale 2.0,
      # set-column-width "100" will make the column occupy 200 physical screen pixels.
      "Mod+Minus".action.set-column-width = "-10%";
      "Mod+Equal".action.set-column-width = "+10%";

      # Finer height adjustments when in column with other windows.
      "Mod+Shift+Minus".action.set-window-height = "-10%";
      "Mod+Shift+Equal".action.set-window-height = "+10%";

      # Move the focused window between the floating and the tiling layout.
      "Mod+V".action.toggle-window-floating = { };
      "Mod+Shift+V".action.switch-focus-between-floating-and-tiling = { };

      # Toggle tabbed column display mode.
      # Windows in this column will appear as vertical tabs,
      # rather than stacked on top of each other.
      "Mod+W".action.toggle-column-tabbed-display = { };

      # Actions to switch layouts.
      # Note: if you uncomment these, make sure you do NOT have
      # a matching layout switch hotkey configured in xkb options above.
      # Having both at once on the same hotkey will break the switching,
      # since it will switch twice upon pressing the hotkey (once by xkb, once by niri).
      # "Mod+Space".action.switch-layout = "next";
      # "Mod+Shift+Space".action.switch-layout = "prev";

      "Print".action.screenshot = {
        show-pointer = false;
      };
      "Ctrl+Print".action.screenshot-screen = {
        show-pointer = false;
      };
      "Alt+Print".action.screenshot-window = { };

      # Applications such as remote-desktop clients and software KVM switches may
      # request that niri stops processing the keyboard shortcuts defined here
      # so they may, for example, forward the key presses as-is to a remote machine.
      # It's a good idea to bind an escape hatch to toggle the inhibitor,
      # so a buggy application can't hold your session hostage.
      #
      # The allow-inhibiting=false property can be applied to other binds as well,
      # which ensures niri always processes them, even when an inhibitor is active.
      "Mod+Escape" = {
        action.toggle-keyboard-shortcuts-inhibit = { };
        allow-inhibiting = false;
      };

      # The quit action will show a confirmation dialog to avoid accidental exits.
      "Mod+Shift+E".action.quit = { };
      "Ctrl+Alt+Delete".action.quit = { };

      # Powers off the monitors. To turn them back on, do any input like
      # moving the mouse or pressing any other key.
      "Mod+Shift+P".action.power-off-monitors = { };
    };

    # Startup applications
    spawn-at-startup = [
      # { command = [ "/home/armand/Pictures/Wallpaper/wallpaper.sh" ]; }
      { command = [ "waybar" ]; }
      { command = [ "mako" ]; }
    ];
  };
}
