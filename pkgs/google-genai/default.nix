{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "google-genai";
  version = "1.2.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "googleapis";
    repo = "python-genai";
    rev = "v${version}";
    hash = "sha256-aoD2dSv35yZQt+4QTc1lP5koCEroY3Wu3p4fP2xTyq8=";
  };

  build-system = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  dependencies = with python3.pkgs; [
    google-auth
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
