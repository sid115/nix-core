{
  pkgs ? import <nixpkgs> { },
}:

pkgs.mkShell {
  buildInputs = [
    (pkgs.python312.withPackages (
      p: with p; [
      ]
    ))
  ];
}
