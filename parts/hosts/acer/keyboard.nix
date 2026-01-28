{ pkgs, ... }:
{
  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "be_custom";

    extraLayouts.be_custom = {
      description = "Belgian (Custom)";
      languages = [
        "nld"
        "fra"
      ];
      symbolsFile = ./be_custom;
    };
  };
}
