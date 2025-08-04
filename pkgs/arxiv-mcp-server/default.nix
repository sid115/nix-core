{
  lib,
  python3,
  fetchPypi,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "arxiv-mcp-server";
  version = "0.2.11";
  pyproject = true;

  src = fetchPypi {
    pname = "arxiv_mcp_server";
    inherit version;
    hash = "sha256-JDA7b8fDGvlDgWSEPTi37OtMFPhWvuMsAwZ1mELj/yg=";
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
    dev = [
      black
    ];
    test = [
      aioresponses
      pytest
      pytest-asyncio
      pytest-cov
      pytest-mock
    ];
  };

  pythonImportsCheck = [
    "arxiv_mcp_server"
  ];

  meta = {
    description = "A flexible arXiv search and analysis service with MCP protocol support";
    homepage = "https://pypi.org/project/arxiv-mcp-server";
    license = with lib.licenses; [ asl20 mit ];
    maintainers = with lib.maintainers; [ ];
    mainProgram = "arxiv-mcp-server";
  };
}
