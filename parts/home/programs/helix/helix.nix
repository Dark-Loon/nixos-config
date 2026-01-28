{ pkgs, lib, ... }:
{
  programs.helix = {
    enable = true;
    settings = {
      theme = "nord_night_transparent";
      editor.cursor-shape = {
        normal = "block";
        insert = "bar";
        select = "underline";
      };
    };
    languages.language = [
      {
        name = "nix";
        auto-format = true;
        formatter.command = "${pkgs.nixfmt}/bin/nixfmt";
      }
      {
        name = "java";
        language-servers = [ "java-language-server" ];
      }
      {
        name = "elm";
        language-servers = [ "elm-language-server" ];
      }
      {
        name = "haskell";
        language-servers = [ "haskell-language-server" ];
      }
      {
        name = "php";
        language-servers = [ "phpactor" ];
      }
      {
        name = "rust";
        language-servers = [ "rust-analyzer" ];
      }
      {
        name = "python";
        language-servers = [ "pylsp" ];
      }
      {
        name = "typst";
        language-servers = [ "tinymist" ];
      }
      {
        name = "typescript";
        language-servers = [ "typescript-language-server" ];
      }
    ];
    themes = {
      autumn_night_transparent = {
        "inherits" = "autumn_night";
        "ui.background" = { };
      };
    };
  };
}
