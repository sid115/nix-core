{
  lib,
  python,
  fetchFromGitHub,
}:

python.pkgs.buildPythonApplication rec {
  pname = "pdftext";
  version = "0.6.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "VikParuchuri";
    repo = "pdftext";
    rev = "v${version}";
    hash = "sha256-mmxNrjEXQ5J5aZkn0+iXAamNBnu1RWdqLe5MjJGwkp0=";
  };

  pythonRelaxDeps = [
    "pypdfium2"
  ];

  build-system = [
    python.pkgs.poetry-core
  ];

  dependencies = with python.pkgs; [
    click
    numpy
    pydantic
    pydantic-settings
    pypdfium2
  ];

  pythonImportsCheck = [
    "pdftext"
  ];

  meta = {
    description = "Extract structured text from pdfs quickly";
    homepage = "https://github.com/VikParuchuri/pdftext";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "pdftext";
  };
}
