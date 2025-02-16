{
  python312,
}:

let
  python = python312; # FIXME: Change this to your Python version
in
python.pkgs.buildPythonApplication {
  pname = "hello"; # FIXME: Change this to your package name
  version = "0.1"; # FIXME: Change this to your package version
  pyproject = true;

  src = ./.;

  build-system = [
    python.pkgs.setuptools
    python.pkgs.wheel
  ];

  # FIXME: Add your dependencies
  dependencies = with python.pkgs; [
  ];

  # FIXME: List your module imports
  pythonImportsCheck = [
    "hello"
  ];
}
