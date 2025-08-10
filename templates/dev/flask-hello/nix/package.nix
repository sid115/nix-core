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

    mkdir -p $out/{bin,share}
    cp -r $src/${pname} $out/bin/
    cp $src/app.py $out/bin/
    chmod +x $out/bin/app.py

    runHook postInstall
  '';

  doCheck = false;
}
