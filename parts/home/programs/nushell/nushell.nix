{ ... }:
{
  programs.nushell = {
    enable = true;
    extraEnv = ''
    $env.PATH = ($env.PATH | prepend ($env.HOME | path join ".cargo" "bin"))
    $env.EDITOR = "hx"
    $env.SOPS_AGE_KEY_CMD = "ssh-to-age -private-key -i /home/armand/.ssh/id_ed25519"
    $env.ANTHROPIC_API_KEY = (open /home/armand/.secrets/anthropic_key | str trim)

    if ($env.HOME | path join '.secrets' | path exists) {
      ls ($env.HOME | path join '.secrets')
        | where type == file
        | each { |f|
            { ($f.name | path basename): (open $f.name | str trim) }
          }
        | into record   # merges list of single-key records → one record
        | load-env      # loads the whole record into env at outer scope
    }
    '';
    extraConfig = ''
      use std/config *
      use ~/.cache/stf/completions.nu *

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

      def --env y [...args: string] {
        if ("ZELLIJ" in $env) {
          if (which foot | is-not-empty) {
            ^foot -e yazi ...$args &
          } else {
            ^ghostty -e yazi ...$args &
          }
        } else {
          let tmp = (mktemp -t "yazi-cwd.XXXXX")
          ^yazi ...$args --cwd-file $tmp
          let cwd = (open $tmp | str trim)
          if $cwd != "" and $cwd != $env.PWD {
            cd $cwd
          }
          rm -f $tmp
        }
      }

      def dvt [
        template: string  # Template name (python, rust, etc.)
        name?: string     # Optional project name
      ] {
        let project_name = ($name | default "my-project")
        let template_lower = ($template | str downcase)

        let template_path = match $template_lower { # ← Match against user input
          "elm" | "e" => "git+file:///home/armand/dotfiles#elm",
          "go" | "g" => "git+file:///home/armand/dotfiles#go",          
          "haskell" | "h" => "git+file:///home/armand/dotfiles#haskell",
          "java" | "j" => "git+file:///home/armand/dotfiles#java",
          "rust" | "r" => "git+file:///home/armand/dotfiles#rust",
          "typst" | "t" => "git+file:///home/armand/dotfiles#typst",
          "typescript" | "ts" => "git+file:///home/armand/dotfiles#typescript",          
          "javascript" | "js" => "git+file:///home/armand/dotfiles#javascript",          
          _ => {
            print $"Unknown template: ($template_lower)"
            print "Available: elm, go, haskell, java,, javascript, rust, typescript, typst"
            return
          }
        }

        mkdir $project_name
        cd $project_name
        nix flake init -t $template_path
        direnv allow
        print $"✅ Project ($project_name) initialized with ($template_lower)"
      }

      def find-pkms [] {
          let name = ($env | get -o PKMS_NAME | default "PKMS")
          let results = (
              glob $"($env.HOME)/**/($name)" --depth 5
              | where { |p| ($p | path type) == "dir" }
          )
          if ($results | is-empty) { null } else { $results | first }
      }

      def parse-fm [file: string] {
          let raw = (open --raw $file)
          if not ($raw | str starts-with "---") { return {} }
          let fm_block = ($raw | str replace -r '(?s)^---\n(.*?)\n---.*' '$1')
          let parsed = (try { $fm_block | from yaml } catch { {} })
          # from yaml returns a bare string for scalar frontmatter — guard against it
          if ($parsed | describe | str starts-with "record") { $parsed } else { {} }
      }

      def f [...terms: string] {
          if ($terms | is-empty) {
              print "Usage: f <term> [term2 ...]"
              print "Quoted phrases: f 'international law' extradition"
              return
          }

          let pkms = (find-pkms)
          if $pkms == null {
            print "No PKMS directory found under $HOME (depth 5). Is it named 'PKMS'?"
            return
          }

          let seed = (try { rg -ilF ($terms | first) $pkms | lines } catch { [] })

          $seed
          | where { |f| $f | str ends-with ".md" }
          | each { |f|
              let term_hits = (
                  $terms | each { |t| try { rg -icF $t $f | into int } catch { 0 } }
              )
              { f: $f, term_hits: $term_hits }
          }
          | where { |r| $r.term_hits | all { |h| $h > 0 } }
          | each { |r|
              let fm    = (parse-fm $r.f)
              let tags  = ($fm | get -o tags | default [])
              {
                  file:       ($r.f | path relative-to $pkms)
                  title:      ($fm | get -o title | default ($r.f | path basename))
                  tags:       $tags
                  hits:       ($r.term_hits | math sum)
                  matched_in: (
                      if ($terms | any { |t| $tags | any { |tag| $tag =~ $t } })
                      { "tags+content" } else { "content only" }
                  )
              }
          }
          | sort-by hits --reverse
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
      tb = "nc termbin.com 9999";
    };
  };
}
