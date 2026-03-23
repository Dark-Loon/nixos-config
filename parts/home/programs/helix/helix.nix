{ pkgs, config, ... }:
{
  home.packages = with pkgs; [
    (writeScriptBin "md-preview-watch" ''
      #!/usr/bin/env nu 
      def main [
        filename: string
      ] {
        let dir = ($filename | path dirname)
        let basename = ($filename | path basename)
        clear
        ^glow -s dark $filename
        ^watchexec --watch $"($dir)" --filter $"($basename)" --debounce 1ms --shell=none --on-busy-update=restart -- glow -s dark $"($filename)"
      }
    '')
    (writeScriptBin "md-preview" ''
      #!/usr/bin/env nu 
      def main [filename: string] {
        ^open-terminal $"md-preview-watch '($filename)'"
      }
    '')
    (writeScriptBin "open-terminal" ''
      #!/usr/bin/env nu   
      def main [cmd: string] {
        if (which zellij | is-not-empty) and ("ZELLIJ" in $env) {
          # already inside zellij, open a new pane
          ^zellij action new-pane --direction right -- nu -c $cmd
        } else if ("GHOSTTY_BIN_DIR" in $env) {
          ^ghostty -e nu -c $cmd
        } else {
          ^foot nu -c $cmd
        }
      }
    '')
    (writeScriptBin "file-preview" ''
      #!/usr/bin/env nu 
      def main [
        filename: string
      ] {
        let ext = ($filename | path parse | get extension)
        match $ext {
          "typ" => { ^zathura-opener $filename }
          "md" => { ^md-preview $filename }
          "pdf" => { ^zathura $filename }
        }
      }
    '')
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
      keys.normal.space.z = ":sh file-preview (realpath $'%{buffer_name}')";
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
