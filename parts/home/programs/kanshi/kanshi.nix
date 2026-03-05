{ ... }:
{
  services.kanshi = {
    enable = true;
    settings = [
      {
        profile.name = "laptop-only";
        profile.outputs = [
          {
            criteria = "LG Display 0x044F";
            mode = "1920x1080@60Hz";
          }
        ];
      }
      {
        profile.name = "with-external";
        profile.outputs = [
          {
            criteria = "LG Display 0x044F";
            status = "disable";
          }
          {
            criteria = "LG Electronics LG FULL HD";
            status = "enable";
            mode = "1920x1080@60Hz";
          }
        ];
      }
    ];
  };  
}
