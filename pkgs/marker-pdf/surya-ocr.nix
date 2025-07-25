{
  lib,
  python,
  fetchPypi,
}:

python.pkgs.buildPythonApplication rec {
  pname = "surya-ocr";
  version = "0.14.6";
  pyproject = true;

  src = fetchPypi {
    pname = "surya_ocr";
    inherit version;
    hash = "sha256-yFoL2d0AyGq0TtJlwO0VYBEG268tDQoGf6e7UzE31fA=";
  };

  pythonRelaxDeps = [
    "opencv-python-headless"
    "pillow"
    "pypdfium2"
    "einops"
  ];

  pythonRemoveDeps = [
    "pre-commit"
  ];

  build-system = [
    python.pkgs.poetry-core
  ];

  dependencies = with python.pkgs; [
    click
    einops
    filetype
    opencv-python-headless
    pillow
    platformdirs
    pydantic
    pydantic-settings
    pypdfium2
    python-dotenv
    torch
    transformers
  ];

  pythonImportsCheck = [
    "surya"
  ];

  meta = {
    description = "OCR, layout, reading order, and table recognition in 90+ languages";
    homepage = "https://pypi.org/project/surya-ocr/";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ];
  };
}
