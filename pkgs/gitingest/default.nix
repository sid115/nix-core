{
  lib,
  python3,
  fetchFromGitHub,
  fetchPypi,
}:

let
  fastapi-analytics = import ./fastapi-analytics.nix { inherit lib python3 fetchPypi; };
in
python3.pkgs.buildPythonApplication {
  pname = "gitingest";
  version = "unstable-2025-01-24";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "cyclotruc";
    repo = "gitingest";
    rev = "b34b7f47a1dd7abb809ce8d1facff22c617acdb1";
    hash = "sha256-VYUWywfkBybQGAuR0nWnwUUQzbZuRd6COYvdbxZxB1E=";
  };

  build-system = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  dependencies = with python3.pkgs; [
    click
    fastapi
    fastapi-analytics
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
    description = "Replace 'hub' with 'ingest' in any github url to get a prompt-friendly extract of a codebase";
    homepage = "https://github.com/cyclotruc/gitingest";
    license = lib.licenses.mit;
    mainProgram = "gitingest";
  };
}
