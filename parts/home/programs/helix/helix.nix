{ pkgs, config, ... }:
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
          language-servers = [ "nixd" ];
        }
        {
          name = "css";
          language-servers = [ "vscode-css-language-server" ];
        }
        {
          name = "java";
          language-servers = [ "jdtls" ];
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
          name = "go";
          language-servers = [ "gopls" ];
        }
        {
          name = "typst";
          language-servers = [ "tinymist" ];
        }
        {
          name = "typescript";
          language-servers = [ "typescript-language-server" ];
        }
        {
          name = "javascript";
          language-servers = [ "typescript-language-server" ];
          file-types = [
            "js"
            "jsx"
            "mjs"
            "cjs"
          ];
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
      language-server.nil = {
        command = "${pkgs.nil}/bin/nil";
      };
      language-server.jdtls = {
        command = "jdtls";
        args = [
          "-data"
          "${config.home.homeDirectory}/.jdtls-workspace"
        ];
      };
      language-server.jdtls.config.java = {
        inlayHints = {
          parameterNames.enabled = "all";
        };
        errors.incompleteClasspath.severity = "ignore";
        autobuild.enabled = false;
        import.maven.enabled = true;
        maven.downloadSources = true;
        configuration.updateBuildConfiguration = "automatic";
        completion.enabled = true;
        signatureHelp.enabled = true;
        contentProvider.preferred = "fernflower";
        eclipse.downloadSources = true;
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
