{ pkgs, ... }:
{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    fd
    fzf
    git
    git-lfs
    helix # Modal CLI text editor
    nushell
    foot
    wget # Tool for retrieving files using HTTP, HTTPS, and FTP
    ripgrep
    findutils # GNU Find Utilities, the basic directory searching utilities of the GNU operating system
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
  ];
}
