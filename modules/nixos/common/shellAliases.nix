{
  environment.shellAliases = {
    l = "ls -lh";
    ll = "ls -lAh";
    ports = "sudo ss -tulpn";
    publicip = "curl ifconfig.me/all";
    sudo = "sudo "; # make aliases work with `sudo`
    v = "nvim";
    vim = "nvim";

    # systemd
    userctl = "systemctl --user";
    enable = "systemctl --user enable";
    disable = "systemctl --user disable";
    start = "systemctl --user start";
    stop = "systemctl --user stop";
    journal = "journalctl --user";

    # git
    ga = "git add";
    gb = "git branch";
    gc = "git commit";
    gcl = "git clone";
    gco = "git checkout";
    gd = "git diff";
    gf = "git fetch --all";
    gl = "git log";
    gm = "git merge";
    gp = "git push";
    gpl = "git pull";
    gr = "git remote";
    gs = "git status";

    # documentation
    # visit `https://teu5us.github.io/nix-lib.html` for builtins and lib functions
    hmopt = "manix --source hm-options";
    nixosopt = "manix --source nixos-options";
    nixpkgs = "manix --source nixpkgs-tree";
  };
}
