# See https://github.com/NixOS/nixpkgs/pull/410836
{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "mcpo";
  version = "0.0.19";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "open-webui";
    repo = "mcpo";
    rev = "v${version}";
    hash = "sha256-ZfTVMrXXEsEKHmeG4850Hq3MEpQA/3WMpAVZS0zvp1I=";
  };

  build-system = [
    python3.pkgs.hatchling
  ];

  dependencies = with python3.pkgs; [
    click
    fastapi
    mcp
    passlib
    pydantic
    pyjwt
    python-dotenv
    typer
    uvicorn
    watchdog
  ];

  pythonRelaxDeps = [
    "mcp"
  ];

  pythonImportsCheck = [
    "mcpo"
  ];

  meta = {
    description = "A simple, secure MCP-to-OpenAPI proxy server";
    homepage = "https://github.com/open-webui/mcpo";
    changelog = "https://github.com/open-webui/mcpo/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "mcpo";
  };
}
