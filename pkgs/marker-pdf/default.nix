{
  lib,
  python3,
  fetchFromGitHub,
  fetchurl,

  packageOverrides ? self: super: { },
}:

let
  fontFileName = "GoNotoCurrent-Regular.ttf";

  fetchFont = fetchurl {
    url = "https://models.datalab.to/artifacts/${fontFileName}";
    hash = "sha256-iCr7q5ZWCMLSvGJ/2AFrliqlpr4tNY+d4kp7WWfFYy4=";
  };

  defaultOverrides = [
  ];

  python = python3.override {
    self = python;
    packageOverrides = lib.composeManyExtensions (defaultOverrides ++ [ packageOverrides ]);
  };

  pdftext = import ./pdftext.nix { inherit lib python fetchFromGitHub; };
  surya-ocr = import ./surya-ocr.nix { inherit lib python fetchFromGitHub; };
in

python.pkgs.buildPythonApplication rec {
  pname = "marker-pdf";
  version = "1.7.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "VikParuchuri";
    repo = "marker";
    rev = "v${version}";
    hash = "sha256-tZxD+sosYazNJNZAn9gTp97Ho81xFInD9aQv5H8rspw=";
  };

  patches = [
    ./skip-font-download.patch
  ];

  pythonRelaxDeps = [
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
      requests
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
    description = "Convert PDF to markdown + JSON quickly with high accuracy";
    homepage = "https://github.com/VikParuchuri/marker";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "marker-pdf";
  };
}
