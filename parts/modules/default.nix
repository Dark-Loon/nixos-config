{
  pkgs,
  inputs,
  config,
  ...
}:
{
  imports = [
    ./theme.nix
    ./ghostty.nix
  ];
}
