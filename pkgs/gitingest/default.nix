{
  lib,
  python312,
  fetchPypi,
}:

python312.pkgs.buildPythonApplication rec {
  pname = "gitingest";
  version = "0.1.3";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-5U4qIzkdBs7w7vzTR5OX19htCy/12+LfdNwYn8MlVig=";
  };

  build-system = [
    python312.pkgs.setuptools
    python312.pkgs.wheel
  ];

  dependencies = with python312.pkgs; [
    click
    fastapi
    python-dotenv
    slowapi
    starlette
    tiktoken
    uvicorn
  ];

  pythonImportsCheck = [
    "gitingest"
  ];

  meta = {
    description = "CLI tool to analyze and create text dumps of codebases for LLMs";
    homepage = "https://pypi.org/project/gitingest";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "gitingest";
  };
}
