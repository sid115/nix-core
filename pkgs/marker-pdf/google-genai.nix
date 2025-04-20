{
  lib,
  python,
  fetchFromGitHub,
}:

python.pkgs.buildPythonApplication rec {
  pname = "google-genai";
  version = "1.9.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "googleapis";
    repo = "python-genai";
    rev = "v${version}";
    hash = "sha256-93y+ScBaeUYl15apu47pTAvJVrF0PWRmMxRHz4MLGZA=";
  };

  build-system = [
    python.pkgs.setuptools
    python.pkgs.wheel
  ];

  dependencies = with python.pkgs; [
    anyio
    google-auth
    httpx
    pydantic
    requests
    typing-extensions
    websockets
  ];

  pythonImportsCheck = [
    "google.genai"
  ];

  meta = {
    description = "Google Gen AI Python SDK provides an interface for developers to integrate Google's generative models into their Python applications";
    homepage = "https://github.com/googleapis/python-genai";
    changelog = "https://github.com/googleapis/python-genai/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "python-genai";
  };
}
