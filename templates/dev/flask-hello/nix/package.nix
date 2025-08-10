{
  python3,
  ...
}:

python3.pkgs.buildPythonApplication rec {
  pname = "flask_hello";
  version = "0.1.0";
  pyproject = true;

  build-system = [ python3.pkgs.setuptools ];

  dependencies = with python3.pkgs; [
    flask
  ];

  src = ../.;

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r $src/${pname} $out/
    cp $src/app.py $out/
    chmod +x $out/app.py

    runHook postInstall
  '';

  doCheck = false;
}
