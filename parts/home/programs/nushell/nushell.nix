{ pkgs, lib, ... }:
{
  programs.nushell = {
    enable = true;
    extraConfig = ''
      use std/config *

      $env.config.hooks.env_change.PWD = $env.config.hooks.env_change.PWD? | default []

      $env.config.hooks.env_change.PWD ++= [{||
        if (which direnv | is-empty) {
          # If direnv isn't installed, do nothing
          return
        }

        direnv export json | from json | default {} | load-env
        # If direnv changes the PATH, it will become a string and we need to re-convert it to a list
        $env.PATH = do (env-conversions).path.from_string $env.PATH
      }]

      $env.config.buffer_editor = "hx"
      $env.config.show_banner = false
      $env.config.completions.case_sensitive = false
      $env.config.completions.quick = true
      $env.config.completions.partial = true
      $env.config.completions.algorithm = "fuzzy"
      $env.config.completions.external.enable = true
      $env.config.completions.external.max_results = 100

      # Define completers BEFORE referencing them
      let carapace_completer = {|spans: list<string>|
          carapace $spans.0 nushell ...$spans
          | from json
          | if ($in | default [] | where value == $"($spans | last)ERR" | is-empty) { $in } else { null }
      }

      $env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'

      let zoxide_completer = {|spans|
          $spans | skip 1 | zoxide query -l ...$in | lines | where {|x| $x != $env.PWD}
      }

      let multiple_completers = {|spans|
          # alias fixer start
          let expanded_alias = scope aliases
          | where name == $spans.0
          | get -o 0.expansion

          let spans = if $expanded_alias != null {
            $spans
            | skip 1
            | prepend ($expanded_alias | split row ' ' | take 1)
          } else {
            $spans
          }
          # alias fixer end

          match $spans.0 {
            __zoxide_z | __zoxide_zi => $zoxide_completer
            _ => $carapace_completer
          } | do $in $spans
      }

      # NOW set the completer to use the variable
      $env.config.completions.external.completer = $multiple_completers

      # yazi integration
      def --env y [...args] {
        let tmp = (mktemp -t "yazi-cwd.XXXXXX")
        yazi ...$args --cwd-file $tmp
        let cwd = (open $tmp)
        if $cwd != "" and $cwd != $env.PWD {
          cd $cwd
        }
        rm -fp $tmp
      }

      def dvt [
        template: string  # Template name (python, rust, etc.)
        name?: string     # Optional project name
      ] {
        let project_name = ($name | default "my-project")
        let template_lower = ($template | str downcase)

        let template_path = match $template_lower { # ← Match against user input
          "elm" | "e" => "gitlab:Darkloon/dotfiles#elm",
          "haskell" | "h" => "gitlab:Darkloon/dotfiles#haskell",
          "java" | "jv" => "gitlab:Darkloon/dotfiles#java",
          "python" | "py" => "gitlab:Darkloon/dotfiles#python",
          "rust" | "rs" => "gitlab:Darkloon/dotfiles#rust",
          "typescript" | "ts" => "gitlab:Darkloon/dotfiles#typescript",
          _ => {
            print $"Unknown template: ($template_lower)"
            print "Available: elm, haskell, java python, rust, typescript"
            return
          }
        }

        mkdir $project_name
        cd $project_name
        nix flake init -t $template_path
        direnv allow
        print $"✅ Project ($project_name) initialized with ($template_lower)"
      }
    '';

    shellAliases = {
      vi = "hx";
      vim = "hx";
      nano = "hx";
      g = "git";
      lla = "ls -la";
      la = "ls -a";
      ll = "ls -l";
      l = "ls";
    };
  };
}
