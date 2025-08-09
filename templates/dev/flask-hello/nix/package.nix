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

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp -r $src/src/*.py $out/bin/
    cp -r $src/src/static $out/
    chmod +x $out/bin/app.py

    runHook postInstall
  '';

  doCheck = false;

  meta.mainProgram = "app.py";
}
