{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "pdftext";
  version = "unstable-2025-02-13";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "sid115";
    repo = "pdftext";
    rev = "be948fa78c858525139a40f4b6d2ce5160622295";
    hash = "sha256-Mp1F88r1LFxF3DYQSa9HeHIIps6Dys+IcTrchUxKX78=";
  };

  build-system = [
    python3.pkgs.poetry-core
  ];

  dependencies = with python3.pkgs; [
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
    homepage = "https://github.com/sid115/pdftext";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "pdftext";
  };
}
