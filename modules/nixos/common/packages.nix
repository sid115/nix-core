{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    cryptsetup
    dig
    fzf
    git
    htop
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
