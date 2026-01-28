{
  pkgs,
  inputs,
  config,
  ...
}:
{
  imports = [
    ./carapace
    ./niri
    ./nushell
    ./starship
    ./waybar
    ./wlogout
    ./yazi
  ];
}
