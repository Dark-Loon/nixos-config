{ pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    (writeScriptBin "zathura-opener" ''
      #!/usr/bin/env nu 
      def main [
        filename: string
      ] {
        let basename = ($filename | path parse | get stem)
        let pdf_path = ($basename + ".pdf")
        ^zathura $pdf_path
      }
    '')
  ];
  programs.helix = {
    enable = true;
    settings = {
      theme = "catppuccin_macchiato";
      editor = {
        shell = [
          "nu"
          "-c"
        ];
        cursor-shape = {
          normal = "block";
          insert = "bar";
          select = "underline";
        };
      };
      keys.normal.space.z = ":sh zathura-opener %{buffer_name}";
    };
    languages = {
      language = [
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
      language-server.tinymist = {
        command = "tinymist";
        config = {
          exportPdf = "onType";
        };
      };
      language-server.hls = {
        command = "haskell-language-server-wrapper";
        args = [ "--lsp" ];
      };
    };
    # themes = {
    #   nord_night_transparent = {
    #     "inherits" = "nord_night";
    #     "ui.background" = { };
    #   };
    # };
  };
}
