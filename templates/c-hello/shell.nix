{
  pkgs ? import <nixpkgs> { },
}:

pkgs.mkShell {
  buildInputs = with pkgs; [
    coreutils
    gcc
    gdb
    gnumake
  ];
}
