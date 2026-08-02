{ pkgs, ... }:
{
  programs.direnv.enableZshIntegration = true;

  programs.zsh = {
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      size = 50000;
      save = 50000;
      ignoreDups = true;
      share = true;
    };

    shellAliases = {
      # Better coreutils
      ls = "eza --icons=auto";
      ll = "eza -la --icons=auto --git";
      lt = "eza --tree --icons=auto -L 2";
      la = "eza -a --icons=auto";
      cat = "bat --paging=never";
      grep = "rg";
      find = "fd";

      # Git shortcuts
      g = "git";
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gpl = "git pull";
      gl = "git log --oneline --graph --decorate";
      gd = "git diff";

      # Nix shortcuts
      nb = "nh os boot";
      ns = "nh os switch";
    };

    initContent = ''
      # zoxide — smart directory jumping, replaces cd
      eval "$(zoxide init zsh --cmd cd)"
    '';
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = false;
      format = "$directory$git_branch$git_status$nix_shell$cmd_duration\n$character";

      directory = {
        truncation_length = 4;
        truncate_to_repo = true;
        style = "bold blue";
      };

      git_branch = {
        symbol = " ";
        style = "bold purple";
      };

      git_status = {
        style = "bold red";
        ahead = "⇡$count";
        behind = "⇣$count";
        diverged = "⇕⇡$ahead_count⇣$behind_count";
        modified = "!$count";
        untracked = "?$count";
        staged = "+$count";
      };

      nix_shell = {
        symbol = " ";
        format = "[$symbol$state( \\($name\\))]($style) ";
        style = "bold cyan";
      };

      cmd_duration = {
        min_time = 2000;
        format = "[$duration]($style) ";
        style = "yellow";
      };

      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
      };
    };
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  home.packages = with pkgs; [
    eza
    fd
    zoxide
  ];
}
