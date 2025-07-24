# See https://github.com/coderamp-labs/gitingest/issues/245
{
  lib,
  python3,
  fetchPypi,
  curl,
  git,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "trelis-gitingest-mcp";
  version = "1.1.2";
  pyproject = true;

  src = fetchPypi {
    pname = "trelis_gitingest_mcp";
    inherit version;
    hash = "sha256-ZOoG0nL0+XnyOUPo4qsGTYizAPzSECUr9eSHEp4Hmzc=";
  };

  build-system = [
    python3.pkgs.hatchling
  ];

  dependencies =
    with python3.pkgs;
    [
      gitingest
      mcp
      pathspec
    ]
    ++ [
      curl
      git
    ];

  pythonImportsCheck = [
    "gitingest_mcp"
  ];

  meta = {
    description = "An MCP server for gitingest";
    homepage = "https://pypi.org/project/trelis-gitingest-mcp/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "trelis-gitingest-mcp";
  };
}
