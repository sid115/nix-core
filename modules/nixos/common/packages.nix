{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    cryptsetup
    dig
    fzf
    git
    gptfdisk
    hydra-check
    iproute2
    jq
    lm_sensors
    lsof
    neovim
    # netcat-openbsd # HOTFIX: does not build: https://hydra.nixos.org/build/317878771
    nettools
    nix-init
    nixfmt-rfc-style
    nixos-container
    nmap
    nurl
    p7zip
    pciutils
    psmisc
    rclone
    rsync
    tcpdump
    tldr
    tmux
    tree
    unzip
    usbutils
    wget
    xxd
    zip

    # rebuild script
    (pkgs.writeShellScriptBin "rebuild" (builtins.readFile ./rebuild.sh))
  ];
}
