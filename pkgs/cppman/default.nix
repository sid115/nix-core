{
  lib,
  python3,
  fetchPypi,
  groff,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "cppman";
  version = "0.5.9";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-FaTkCrAltNzsWnOlDfJrfdrvfBSPyxl5QP/ySE+emQM=";
  };

  build-system = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  dependencies = with python3.pkgs; [
    beautifulsoup4
    distutils
    html5lib
    lxml
    six
    soupsieve
    typing-extensions
    webencodings
  ];

  postInstall = ''
    wrapProgram $out/bin/cppman --prefix PATH : "${groff}/bin"
  '';

  pythonRelaxDeps = true;
  pythonRemoveDeps = true; # for bs4

  pythonImportsCheck = [
    "cppman"
  ];

  meta = {
    description = "C++ 98/11/14/17/20 manual pages for Linux/MacOS";
    homepage = "https://pypi.org/project/cppman";
    license = with lib.licenses; [
      gpl3Only
      gpl2Only
    ];
    maintainers = with lib.maintainers; [ ];
    mainProgram = "cppman";
  };
}
