{ ... }:
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
            run = ''swayimg "$@"'';
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
            name = "*.jsx";
            use = "edit";
          }
          {
            name = "*.json";
            use = "edit";
          }
          {
            name = "*.md";
            use = "edit";
          }
          {
            name = "*.js";
            use = "edit";
          }
          {
            name = "*.ts";
            use = "edit";
          }
          {
            name = "*.tsx";
            use = "edit";
          }
          {
            name = "*.php";
            use = "edit";
          }
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
            mime = "text/markdown";
            run = "glow";
          }
          {
            name = "*.md";
            run = "glow";
          }
        ];
      };
    };
  };
}
