{ pkgs, lib, ... }:
{
  programs.carapace = {
    enable = true;
    enableNushellIntegration = true;
  };
}
