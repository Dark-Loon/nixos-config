{ pkgs, ... }:
{
  programs.vscode = {
    enable = true;
    profiles.default = {
      enableUpdateCheck = false;
      userSettings = {
        "terminal.integrated.shellIntegration.enabled" = false;
        "terminal.integrated.defaultProfile.linux" = "nushell";
        "terminal.integrated.profiles.linux" = {
          "nushell" = {
            "path" = "/run/current-system/sw/bin/nu";
          };
        };
      };
      extensions = with pkgs.vscode-extensions; [
        usernamehw.errorlens
        esbenp.prettier-vscode
      ];
    };
  };

  home.file.".vscode/argv.json".text = builtins.toJSON {
    enable-crash-reporter = false;
    password-store = "gnome-libsecret";
  };
}
