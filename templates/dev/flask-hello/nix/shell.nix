{
  pkgs ? import <nixpkgs> { },
  ...
}:

pkgs.mkShell {
  buildInputs = [
    (pkgs.python3.withPackages (
      p: with p; [
        flask
      ]
    ))
    pkgs.nixfmt-tree
    pkgs.black
  ];

  shellHook = ''
    export FLASK_APP=src/app.py
  '';
}
