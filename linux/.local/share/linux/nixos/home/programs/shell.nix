{
  programs = {
    zsh.enable = true;
    eza.enable = true;
    bat.enable = true;
    fzf.enable = true;
    zoxide.enable = true;

    starship = {
      enable = true;
      settings = {

        format = "$directory$character";
        right_format = "$all";

        add_newline = true;
        command_timeout = 1000;
        line_break.disabled = true;
      };
    };
  };
}



