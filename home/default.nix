{ config, pkgs, lib, ... }:

{
  # Configuration for Nix
  nix = {
    package = pkgs.nix;
    settings = {
      sandbox = true;
      experimental-features = [ "flakes" "nix-command" ];
      auto-optimise-store = true;
    };
  };

  home.language = { base = "en_US.UTF-8"; };
  fonts.fontconfig.enable = true;

  # Dotfiles
  xdg = {
    enable = true;
    cacheHome = "${config.home.homeDirectory}/.cache";
    configHome = "${config.home.homeDirectory}/.config";
    dataHome = "${config.home.homeDirectory}/.local/share";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.sessionVariables = {
    EDITOR = "nvim";
    PIP_REQUIRE_VIRTUALENV = "true";
    PAGER = "less -FirSwX";
    DIRENV_LOG_FORMAT = "";
    LESSHISTFILE = "${config.xdg.cacheHome}/less/history";
  };

  editorconfig = {
    enable = true;
    settings = {
      "*" = {
        charset = "utf-8";
        end_of_line = "lf";
        indent_size = 2;
        trim_trailing_whitespace = true;
        insert_final_newline = true;
        indent_style = "space";
      };
      "Makefile" = {
        indent_style = "tab";
      };
      "*.go" = {
        indent_style = "tab";
      };
      "*.md" = {
        trim_trailing_whitespace = false;
      };
      "*.py" = {
        indent_size = 4;
      };
    };
  };

  home.shellAliases = {
    # Navigation
    ".." = "cd ..";
    "..." = "cd ../../";

    # Shortcuts
    "," = "comma";
    p = "cd ~/src";
    diff = "difft";
    cat = "bat -pp";
    grep = "rg";
    find = "fd";
    week = "date +%V";
    tmp = "cd $(mktemp -d)";

    # Kitty aliases
    kssh = "SSH_ASKPASS=ssh kitty +kitten ssh";
    icat = "kitty +kitten icat";
  };

  home.packages = with pkgs; [
    # Programming languages
    python311 # Nice to always have the latest python

    # Shell utilities
    comma
    coreutils
    curl
    fd
    ripgrep
    tree
    bat
    difftastic

    # Fonts
    (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" ]; })

    # Universal dev tools
    git-crypt
    age
    sops
    qemu
    wget
  ];

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
    config = {
      global = {
        load_dotenv = true;
        strict_env = false;
        warn_timeout = "20s";
      };
    };
  };

  programs.dircolors = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.exa = {
    enable = true;
    enableAliases = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.gh = {
    enable = true;
    settings = {
      editor = "nvim";
      git_protocol = "ssh";
      prompt = "enabled";
    };
  };

  programs.gpg = { enable = true; };
  programs.htop = { enable = true; };
  programs.jq = { enable = true; };

  programs.nix-index = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.readline = { enable = true; };
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    enableSyntaxHighlighting = true;
    autocd = true;
    defaultKeymap = "emacs";
    dotDir = ".config/zsh";
    # MacOS clears out /etc/zshrc after updates, so make sure we run nix-daemon.sh
    initExtraFirst = ''
      # Nix
      if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
      fi
      # End Nix
    '';
    # Source local extra settings if it exists
    envExtra = ''
      [ -f $ZDOTDIR/extra.zshenv ] && source $ZDOTDIR/extra.zshenv
    '';
    history = {
      expireDuplicatesFirst = true;
      extended = true;
      ignoreDups = true;
      ignorePatterns = [ "ls *" "exit" "clear" "l" ];
      size = 5000000;
      save = 5000000;
      path = "${config.xdg.dataHome}/zsh/zsh_history";
    };
    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
        name = "powerlevel10k-config";
        src = pkgs.lib.cleanSource ./.;
        file = "p10k.zsh";
      }
      # Use zsh for nix-shell
      {
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "chisui";
          repo = "zsh-nix-shell";
          rev = "v0.5.0";
          sha256 = "0za4aiwwrlawnia4f29msk822rj9bgcygw6a8a6iikiwzjjz0g91";
        };
      }
    ];
  };

  programs.ssh = {
    enable = true;
    forwardAgent = true;
    includes = [ "config.d/*" ];
    extraConfig = ''
      AddKeysToAgent ask
      IgnoreUnknown UseKeychain
      UseKeychain yes
      IdentityFile ~/.ssh/id_ed25519
      SetEnv TERM=xterm-256color
    '';
  };

  programs.git = {
    enable = true;
    userName = "Hannes Ljungberg";
    userEmail = "hannes.ljungberg@gmail.com";
    signing = {
      signByDefault = true;
      key = "89F9502DAC4CA6C1";
    };
    lfs.enable = true;
    difftastic.enable = true;
    extraConfig = {
      apply.whitespace = "fix";
      core.trustctime = false;
      core.whitespace = "space-before-tab,-indent-with-non-tab,trailing-space";
      init.defaultBranch = "main";
      github.user = "hannseman";
      pull.rebase = true;
      fetch.prune = true;
      # Correct typos
      help.autocorrect = 1;
    };
    ignores = [
      "*.pyc"
      ".DS_Store"
      ".direnv/"
      ".idea/"
      "*.swp"
      "npm-debug.log"
      "venv/"
      "node_modules/"
      "._*"
      "Thumbs.db"
      ".Spotlight-V100"
      ".Trashes"
    ];
    aliases = {
      lg =
        "log --graph --pretty='%Cred%h%Creset - %C(bold blue)<%an>%Creset %s%C(yellow)%d%Creset %Cgreen(%cr)' --abbrev-commit --date=relative";
      st = "status -s -b";
      up = "pull --rebase --autostash";
    };
  };

  programs.neovim = {
    enable = true;
    vimAlias = true;
    vimdiffAlias = true;
    viAlias = true;
    plugins = with pkgs.vimPlugins; [ editorconfig-vim gruvbox vim-nix ];
    extraConfig = ''
      :imap jk <Esc>
      :set number
    '';
  };

  programs.tmux = {
    enable = true;
    shortcut = "a";
    clock24 = true;
    escapeTime = 0;
    baseIndex = 1;
    keyMode = "emacs";
    terminal = "screen-256color";
    shell = "${pkgs.zsh}/bin/zsh";
    historyLimit = 5000;
    extraConfig = ''
      set-option -g mouse on

      bind Escape copy-mode

      bind . split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"

      bind c new-window -c "#{pane_current_path}"

      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      bind -r + resize-pane -Z

      bind N previous-window
    '';
  };

  programs.kitty = {
    enable = true;
    font = {
      size = 13;
      name = "JetBrainsMono Nerd Font";
    };
    theme = "Oceanic Material";
    settings = {
      confirm_os_window_close = 2;
      window_padding_width = 10;
      enable_audio_bell = false;
      disable_ligatures = "cursor";
      draw_minimal_borders = "yes";
      inactive_text_alpha = "0.7";
      active_border_color = "none";
      scrollback_lines = 10000;

      macos_titlebar_color = "background";
      macos_thicken_font = "0.75";
      macos_quit_when_last_window_closed = "yes";

      tab_bar_style = "separator";
      tab_separator = "\"   \"";
      tab_bar_margin_width = 10;
      tab_bar_margin_height = "10 0";
      tab_title_template = "{index}:{title}{fmt.fg._ffffff}{layout_name.replace('splits', '').replace('stack', ' ')}";
      active_tab_foreground = "#ff8600";
      active_tab_background = "#1c262b";
      inactive_tab_foreground = "#9de487";
      inactive_tab_background = "#1c262b";

      enabled_layouts = "splits,stack";
    };
    #
    extraConfig = ''
      # Reset url clicking to instead open on cmd+left click
      mouse_map left click ungrabbed no-op
      mouse_map cmd+left release grabbed,ungrabbed mouse_click_url
      mouse_map cmd+left press grabbed mouse_discard_event
    '';

    keybindings = {
      # Keybindings which tries to be as close to iTerm 2 as possible
      "cmd+w" = "close_window";
      "cmd+shift+n" = "new_os_window";

      "cmd+d" = "launch --location=vsplit --cwd=current";
      "cmd+shift+d" = "launch --location=hsplit --cwd=current";
      "cmd+shift+enter" = "toggle_layout stack";

      "cmd+f" = "show_scrollback";

      "cmd+t" = "new_tab";
      "cmd+1" = "goto_tab 1";
      "cmd+2" = "goto_tab 2";
      "cmd+3" = "goto_tab 3";
      "cmd+4" = "goto_tab 4";
      "cmd+5" = "goto_tab 5";
      "cmd+6" = "goto_tab 6";
      "cmd+7" = "goto_tab 7";
      "cmd+8" = "goto_tab 8";
      "cmd+9" = "goto_tab 9";

      "cmd+l" = "next_layout";
    };
  };

  # Workaround for https://github.com/nix-community/home-manager/issues/1341#issuecomment-1190875080
  disabledModules = [ "targets/darwin/linkapps.nix" ];
  home.activation.copyApplications = lib.mkIf pkgs.stdenv.isDarwin (
    let
      apps = pkgs.buildEnv {
        name = "home-manager-applications";
        paths = config.home.packages;
        pathsToLink = "/Applications";
      };
    in
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      baseDir="$HOME/Applications/Home Manager Apps"
      if [ -d "$baseDir" ]; then
        rm -rf "$baseDir"
      fi
      mkdir -p "$baseDir"
      for appFile in ${apps}/Applications/*; do
        target="$baseDir/$(basename "$appFile")"
        $DRY_RUN_CMD cp ''${VERBOSE_ARG:+-v} -fHRL "$appFile" "$baseDir"
        $DRY_RUN_CMD chmod ''${VERBOSE_ARG:+-v} -R +w "$target"
      done
    ''
  );
  # Print package changes
  home.activation.report-changes = config.lib.dag.entryAnywhere ''
    ${pkgs.nvd}/bin/nvd diff $oldGenPath $newGenPath
  '';
}
