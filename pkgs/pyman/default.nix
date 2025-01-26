{
  python3,
  ...
}:

python3.pkgs.buildPythonApplication {
  pname = "pyman";
  version = "1.0.0";

  src = ./.;

  propagatedBuildInputs = [ ];

  doCheck = false;

  meta = {
    description = "A script to display Python help for a given topic";
  };
}
