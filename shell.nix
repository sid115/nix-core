{
  pkgs ? import <nixpkgs> { },
  ...
}:

pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    nixfmt-tree
    pre-commit
    (python313.withPackages (
      p: with p; [
        mkdocs
        mkdocs-material
        mkdocs-material-extensions
        pygments
      ]
    ))
  ];
}
