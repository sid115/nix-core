{
  python3,
  ...
}:

let
  python = python3;
in
python.pkgs.buildPythonApplication {
  pname = "flask-hello";
  version = "0.1.0";
  pyproject = true;

  build-system = [ python.pkgs.setuptools ];

  propagatedBuildInputs = with python.pkgs; [
    flask
  ];

  src = ./src;

  doCheck = false;

  meta.mainProgram = "app.py";
}
