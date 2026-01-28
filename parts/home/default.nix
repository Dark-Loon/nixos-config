{
  pkgs,
  inputs,
  config,
  ...
}:
{
  imports = [
    ./home.nix
    ./programs
  ];
}
