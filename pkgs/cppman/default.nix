{
  lib,
  python3,
  fetchFromGitHub,
  groff,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "cppman";
  version = "0.5.7";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "aitjcize";
    repo = "cppman";
    rev = version;
    hash = "sha256-dqLYYYIqcAdhcn2iRXv7YmYrJAM4w8H57Lu0B2p54cM=";
  };

  nativeBuildInputs = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  propagatedBuildInputs = [
    python3.pkgs.beautifulsoup4
    python3.pkgs.html5lib
    groff
  ];

  pythonImportsCheck = [ "cppman" ];

  meta = with lib; {
    description = "C++ 98/11/14 manual pages for Linux/MacOS";
    homepage = "https://github.com/aitjcize/cppman";
    changelog = "https://github.com/aitjcize/cppman/blob/${src.rev}/ChangeLog";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
    mainProgram = "cppman";
  };
}
