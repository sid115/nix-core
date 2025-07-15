{
  lib,
  python3,
  fetchPypi,
  fetchurl,
}:

let
  fontFileName = "GoNotoCurrent-Regular.ttf";

  fetchFont = fetchurl {
    url = "https://models.datalab.to/artifacts/${fontFileName}";
    hash = "sha256-iCr7q5ZWCMLSvGJ/2AFrliqlpr4tNY+d4kp7WWfFYy4=";
  };

  python = python3;

  pdftext = import ./pdftext.nix { inherit lib python fetchPypi; };
  surya-ocr = import ./surya-ocr.nix { inherit lib python fetchPypi; };
in

python.pkgs.buildPythonApplication rec {
  pname = "marker-pdf";
  version = "1.8.2";
  pyproject = true;

  src = fetchPypi {
    pname = "marker_pdf";
    inherit version;
    hash = "sha256-k2mxOpBBtXdCzxP4hqfXnCEqUF69hQZWr/d9V/tITZ4=";
  };

  patches = [
    ./skip-font-download.patch
    ./fix-output-dir.patch
  ];

  pythonRelaxDeps = [
    "click"
    "anthropic"
    "markdownify"
    "pillow"
  ];

  pythonRemoveDeps = [
    "pre-commit"
  ];

  postInstall = ''
    FONT_DEST_DIR="$out/lib/${python.libPrefix}/site-packages/static/fonts"
    mkdir -p $FONT_DEST_DIR
    cp ${fetchFont} "$FONT_DEST_DIR/${fontFileName}"
    echo "Installed font to $FONT_DEST_DIR/${fontFileName}"
  '';

  build-system = [
    python.pkgs.poetry-core
  ];

  dependencies =
    [
      pdftext
      surya-ocr
    ]
    ++ (with python.pkgs; [
      anthropic
      click
      filetype
      ftfy
      google-genai
      markdown2
      markdownify
      openai
      pillow
      pydantic
      pydantic-settings
      python-dotenv
      rapidfuzz
      regex
      scikit-learn
      torch
      tqdm
      transformers
    ]);

  optional-dependencies = with python.pkgs; {
    full = [
      ebooklib
      mammoth
      openpyxl
      python-pptx
      weasyprint
    ];
  };

  pythonImportsCheck = [
    "marker"
  ];

  meta = {
    description = "Convert documents to markdown with high speed and accuracy";
    homepage = "https://pypi.org/project/marker-pdf/";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ];
  };

}
