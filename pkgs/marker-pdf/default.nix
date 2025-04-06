{
  lib,
  python3,
  fetchFromGitHub,

  packageOverrides ? self: super: { },
}:

let
  defaultOverrides = [
    (self: super: {
      pillow = super.pillow.overridePythonAttrs (oldAttrs: rec {
        version = "10.2.0";
        src = fetchFromGitHub {
          owner = "python-pillow";
          repo = "pillow";
          tag = version;
          hash = "sha256-1oK1MgDjAVpXs8nMm5MgAt/J0binIFbdVf7omsNUPm4=";
        };
      });
    })
  ];

  python = python3.override {
    self = python;
    packageOverrides = lib.composeManyExtensions (defaultOverrides ++ [ packageOverrides ]);
  };

  google-genai = import ./google-genai.nix { inherit lib python fetchFromGitHub; };
  pdftext = import ./pdftext.nix { inherit lib python fetchFromGitHub; };
  surya-ocr = import ./surya-ocr.nix { inherit lib python fetchFromGitHub; };
in

python.pkgs.buildPythonApplication rec {
  pname = "marker-pdf";
  version = "1.6.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "VikParuchuri";
    repo = "marker";
    rev = "v${version}";
    hash = "sha256-tZxD+sosYazNJNZAn9gTp97Ho81xFInD9aQv5H8rspw=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace 'Pillow = "^10.1.0"' 'Pillow = "^10.2.0"' \
      --replace 'anthropic = "^0.46.0"' 'anthropic = "^0.49.0"' \
      --replace 'markdownify = "^0.13.1"' 'markdownify = "^0.14.1"' \
      --replace 'pre-commit = "^4.2.0"' '#pre-commit = "^4.2.0"'
  '';

  build-system = [
    python.pkgs.poetry-core
  ];

  dependencies =
    [
      google-genai
      pdftext
      surya-ocr
    ]
    ++ (with python.pkgs; [
      anthropic
      click
      filetype
      ftfy
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
    description = "Convert PDF to markdown + JSON quickly with high accuracy";
    homepage = "https://github.com/VikParuchuri/marker";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "marker-pdf";
  };
}
