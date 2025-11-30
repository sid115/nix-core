{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    cryptsetup
    dig
    fzf
    git
    hydra-check
    iproute2
    jq
    lm_sensors
    lsof
    neovim
    netcat-openbsd
    nettools
    nix-init
    nixfmt-rfc-style
    nurl
    pciutils
    psmisc
    rsync
    tcpdump
    tldr
    tree
    unzip
    usbutils
    wget
    zip

    # rebuild script
    (pkgs.writeShellScriptBin "rebuild" (builtins.readFile ./rebuild.sh))
  ];
}
