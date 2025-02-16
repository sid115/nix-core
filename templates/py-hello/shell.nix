{
  pkgs ? import <nixpkgs> { },
}:

let
  python = pkgs.python312;
in
pkgs.mkShell {
  packages = [
    (python.withPackages (
      p: with p; [
      ]
    ))
  ];
}
