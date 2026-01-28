{ pkgs, lib, ... }:
{
  programs.yazi = {
    enable = true;

    settings = {
      opener = {
        edit = [
          {
            run = ''hx "$@"'';
            block = true;
          }
        ];
        text = [
          {
            run = ''hx "$@"'';
            block = true;
          }
        ];
        image = [
          {
            run = ''imv "$@"'';
            orphan = true;
          }
        ];
        video = [
          {
            run = ''vlc "$@"'';
            orphan = true;
          }
        ];
        pdf = [
          {
            run = ''zathura "$@"'';
            orphan = true;
          }
        ];
      };

      open = {
        rules = [
          {
            mime = "text/*";
            use = "edit";
          }
          {
            mime = "image/*";
            use = "image";
          }
          {
            mime = "video/*";
            use = "video";
          }
          {
            mime = "application/pdf";
            use = "pdf";
          }
        ];
      };

      plugin = {
        prepend_previewers = [
          {
            name = "*.md";
            run = "glow";
          }
        ];
      };
    };

    initLua = ''
      return {
        peek = function(self)
          local child, err = Command("glow")
            :args({ "-s", "dark", "-w", tostring(self.area.w) })
            :arg(tostring(self.file.url))
            :stdout(Command.PIPED)
            :stderr(Command.PIPED)
            :spawn()

          if not child then
            ya.err("Failed to spawn glow: " .. tostring(err))
            return
          end

          local output = child:wait_with_output()

          if output and output.status and output.status.success then
            ya.preview_widgets(self, {
              ui.Text.parse(output.stdout):area(self.area)
            })
          else
            ya.err("Glow failed: " .. tostring(output.stderr))
          end
        end,

        seek = function() end,
      }
    '';
  };
}
