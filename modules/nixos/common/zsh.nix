{
  programs.zsh = {
    enable = true;
    syntaxHighlighting = {
      enable = true;
      highlighters = [
        "main"
        "brackets"
        "cursor"
        "pattern"
      ];
      patterns = {
        "rm -rf" = "fg=white,bold,bg=red";
        "rm -fr" = "fg=white,bold,bg=red";
      };
    };
    autosuggestions = {
      enable = true;
      strategy = [
        "completion"
        "history"
      ];
    };
    enableLsColors = true;
  };
}
