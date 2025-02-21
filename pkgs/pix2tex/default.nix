{
  lib,
  python312,
  fetchPypi,
}:

python312.pkgs.buildPythonApplication rec {
  pname = "pix2tex";
  version = "0.0.8";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-lsrfzy5siR8OQv4pIYUyW3WWfhPvrtfz9opC+2dMt64=";
  };

  build-system = [
    python312.pkgs.setuptools
    python312.pkgs.wheel
  ];

  dependencies = with python312.pkgs; [
    albumentations
    einops
    einx
    loguru
    munch
    numpy
    opencv-python-headless
    pandas
    pillow
    pyyaml
    requests
    timm
    tokenizers
    torch
    tqdm
    transformers
    x-transformers
  ];

  optional-dependencies = with python312.pkgs; {
    all = [
      fastapi
      imagesize
      latex2sympy2
      pygments
      pynput
      pyqt6
      pyqt6-webengine
      pyside6
      python-levenshtein
      python-multipart
      screeninfo
      st-img-pastebutton
      streamlit
      torchtext
      uvicorn
    ];
    api = [
      fastapi
      python-multipart
      st-img-pastebutton
      streamlit
      uvicorn
    ];
    gui = [
      latex2sympy2
      pynput
      pyqt6
      pyqt6-webengine
      pyside6
      screeninfo
    ];
    highlight = [
      pygments
    ];
    train = [
      imagesize
      python-levenshtein
      torchtext
    ];
  };

  pythonImportsCheck = [
    "pix2tex"
  ];

  meta = {
    description = "Pix2tex: Using a ViT to convert images of equations into LaTeX code";
    homepage = "https://pypi.org/project/pix2tex";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "pix2tex";
  };
}
