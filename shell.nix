{
  pkgs ? import <nixpkgs> { },
  ...
}:

pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    (python313.withPackages (
      p: with p; [
        mkdocs
        mkdocs-material
        mkdocs-material-extensions
      ]
    ))
  ];
}
