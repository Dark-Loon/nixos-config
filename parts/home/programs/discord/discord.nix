{ ... }:
{
  programs.vesktop = {
    enable = true;
    vencord.themes = {
      midnight = builtins.fetchurl {
        url = "https://refact0r.github.io/midnight-discord/build/midnight.css";
        sha256 = "12z5vqkdxpa8jhk67yss4xj8m2h089910dc6hjr12ym03952pfkx";
      };
    };

    vencord.settings = {
      autoUpdate = true;
      autoUpdateNotification = true;
      enabledThemes = [ "midnight.css" ];
      notifyAboutUpdates = true;
      plugins = {
        ClearURLs.enabled = true;
        FixYoutubeEmbeds.enabled = true;
      };
    };
  };
}
