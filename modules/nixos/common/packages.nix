{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    fzf
    git
    htop
    iproute2
    jq
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
    unzip
    usbutils
    wget
    zip

    # rebuild script
    (pkgs.writeShellScriptBin "rebuild" (builtins.readFile ./rebuild.sh))
  ];
}
