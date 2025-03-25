{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "surya-ocr";
  version = "unstable-2025-02-13";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "sid115";
    repo = "surya";
    rev = "7e6e5e628f8560d994a61a7ef165a3c54001fef2";
    hash = "sha256-o7gIEtA2pUEg0Db9HtIeOfcvLEdeVuR6cnNxT89hB3o=";
  };

  build-system = [
    python3.pkgs.poetry-core
  ];

  dependencies = with python3.pkgs; [
    click
    filetype
    opencv-python
    pillow
    pydantic
    pydantic-settings
    pypdfium2
    python-dotenv
    streamlit
    torch
    transformers
  ];

  pythonImportsCheck = [
    "surya"
  ];

  meta = {
    description = "OCR, layout analysis, reading order, table recognition in 90+ languages";
    homepage = "https://github.com/sid115/surya";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "surya-ocr";
  };
}
