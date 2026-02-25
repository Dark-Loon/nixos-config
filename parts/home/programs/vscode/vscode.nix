{ pkgs, ... }:
{
  programs.vscode = {
    enable = true;
    enableUpdateCheck = false;
    extensions = with pkgs.vscode-extensions; [
      anthropic.claude-code
      usernamehw.errorlens
      esbenp.prettier-vscode
    ];
  };
}
