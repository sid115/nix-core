{
  lib,
  python3,
  fetchPypi,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "arxiv-mcp-server";
  version = "0.3.1";
  pyproject = true;

  src = fetchPypi {
    pname = "arxiv_mcp_server";
    inherit version;
    hash = "sha256-yGNetU7el6ZXsavD8uvO17OZtaPuYgzkxiVEk402GUs=";
  };

  build-system = [
    python3.pkgs.hatchling
  ];

  dependencies = with python3.pkgs; [
    aiofiles
    aiohttp
    anyio
    arxiv
    httpx
    mcp
    pydantic
    pydantic-settings
    pymupdf4llm
    python-dateutil
    python-dotenv
    sse-starlette
    uvicorn
  ];

  optional-dependencies = with python3.pkgs; {
    test = [
      aioresponses
      pytest
      pytest-asyncio
      pytest-cov
      pytest-mock
    ];
  };

  pythonRemoveDeps = [
    "black"
  ];

  pythonImportsCheck = [
    "arxiv_mcp_server"
  ];

  meta = {
    description = "A flexible arXiv search and analysis service with MCP protocol support";
    homepage = "https://pypi.org/project/arxiv-mcp-server";
    license = with lib.licenses; [
      asl20
      mit
    ];
    maintainers = with lib.maintainers; [ ];
    mainProgram = "arxiv-mcp-server";
  };
}
