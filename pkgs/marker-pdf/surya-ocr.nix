{
  lib,
  python,
  fetchFromGitHub,
}:

python.pkgs.buildPythonApplication rec {
  pname = "surya-ocr";
  version = "0.13.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "VikParuchuri";
    repo = "surya";
    rev = "v${version}";
    hash = "sha256-8be9NmlqVuDJj7TiVdnGCrpRNbWlA9Fo+6wBiYY7BgM=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace 'pypdfium2 = "=4.30.0"' 'pypdfium2 = "^4.30.0"' \
      --replace 'opencv-python-headless = "^4.11.0.86"' 'opencv-python-headless = "^4.11.0"'
  '';

  build-system = [
    python.pkgs.poetry-core
  ];

  dependencies = with python.pkgs; [
    click
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
    description = "OCR, layout analysis, reading order, table recognition in 90+ languages";
    homepage = "https://github.com/VikParuchuri/surya";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "surya";
  };
}
