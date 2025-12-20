{ pkgs, ... }:
{
  programs.helix = {
    enable = true;
    defaultEditor = true;
    # package = inputs.helix.packages.${pkgs.system}.helix;

    settings = {

      # ================================================================================================
      # Config
      # ================================================================================================

      theme = "catppuccin_mocha";

      editor = {
        continue-comments = false;
        completion-replace = true;
        true-color = true;
        bufferline = "multiple";
        color-modes = true;

        end-of-line-diagnostics = "hint";
        inline-diagnostics.other-lines = "info";
        inline-diagnostics.cursor-line = "warning";

        statusline = {
          separator = "│";
          mode.normal = "NORMAL";
          mode.insert = "INSERT";
          mode.select = "SELECT";
          left = [ "mode" "spinner" ];
          center = [ "file-name" ];
          right = [ "diagnostics" "version-control" ];
        };

        lsp = {
          display-inlay-hints = true;
          display-progress-messages = true;
        };

        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };

        soft-wrap = {
          enable = true;
          max-wrap = 25;
          wrap-indicator = "↪ ";
          wrap-at-text-width = false;
        };
      };

      keys.normal = {
        space.q = ":q";
        space.space = ":w";
        space.p = "@:sh python <C-r>%<ret>";
        space.c = "@:sh gcc <C-r>%<ret> && ./main";

        C-q = ":q!";

        del = ":buffer-close!";
        esc = [ "collapse_selection" "keep_primary_selection" ];
      };
    };

    # ================================================================================================
    # LSP
    # ================================================================================================

    languages = {

      language = [
        {
          name = "c";
          auto-format = true;
          indent = { tab-width = 4; unit = "    "; };
          formatter = { command = "${pkgs.clang-tools}/bin/clang-format"; args = [ "--style=LLVM" ]; };
        }
        {
          name = "nix";
          auto-format = true;
          formatter = { command = "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt"; };
        }
        {
          name = "yaml";
          auto-format = true;
          formatter = { command = "${pkgs.yamlfmt}/bin/yamlfmt"; args = [ "-w" ]; stdin = false; };
        }
        {
          name = "bash";
          auto-format = true;
          formatter = { command = "${pkgs.shfmt}/bin/shfmt"; args = [ "-i" "2" "-ci" ]; };
        }
        {
          name = "python";
          auto-format = true;
          language-servers = [ "pyright" "ruff" ];
          formatter = { command = "${pkgs.ruff}/bin/ruff"; args = [ "format" "-" ]; };
        }
        # {
        #   name = "markdown";
        #   auto-format = true;
        #   formatter = { command = "${pkgs.dprint}/bin/dprint"; args = [ "fmt" "--stdin" "md" ]; };
        # }
      ];

      language-server = {

        nixd = {
          command = "${pkgs.nixd}/bin/nixd";
        };

        ruff = {
          command = "${pkgs.ruff}/bin/ruff";
          args = [ "server" "--preview" ];
          config.setting = { organizeImports = true; };
        };

        clangd = {
          command = "clangd";
          args = [ "--clang-tidy" "-j=5" "--malloc-trim" ];
        };
      };

      # ================================================================================================
      # Needed Packages
      # ================================================================================================

      extraPackages = with pkgs; [

        lldb
        clang
        clang-tools
        clang-analyzer

        ruff
        pyright
        python313Packages.debugpy

        texlab
        ltex-ls-plus

        marksman
        markdown-oxide

        nixd
        nodePackages.bash-language-server
      ];
    };
  };
}

