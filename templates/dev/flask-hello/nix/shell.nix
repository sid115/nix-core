{
  pkgs ? import <nixpkgs> { },
  ...
}:

pkgs.mkShell {
  buildInputs = [
    (pkgs.python3.withPackages (
      p: with p; [
        flask
        gunicorn
      ]
    ))
    pkgs.nixfmt-tree
    pkgs.black
  ];
}
