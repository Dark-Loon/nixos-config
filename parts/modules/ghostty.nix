{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.ghostty = {
    enable = true;

    package = pkgs.symlinkJoin {
      name = "ghostty-wrapped";
      paths = [ pkgs.ghostty ];
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/ghostty \
          --set LIBGL_ALWAYS_SOFTWARE 1 \
          --set GALLIUM_DRIVER llvmpipe
      '';
    };
  };
  xdg.desktopEntries.ghostty = {
    name = "Ghostty";
    exec = "ghostty";
    terminal = false;
    categories = [
      "System"
      "TerminalEmulator"
    ];
    icon = "${pkgs.ghostty}/share/icons/hicolor/128x128/apps/com.mitchellh.ghostty.png";
  };
}
