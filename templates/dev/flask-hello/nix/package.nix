{
  python3,
  ...
}:

python3.pkgs.buildPythonApplication {
  pname = "flask-hello";
  version = "0.1.0";
  pyproject = true;

  build-system = [ python3.pkgs.setuptools ];

  dependencies = with python3.pkgs; [
    flask
  ];

  src = ../.;

  doCheck = false;
}
