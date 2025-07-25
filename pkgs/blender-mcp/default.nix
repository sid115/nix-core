{
  lib,
  python3,
  fetchPypi,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "blender-mcp";
  version = "1.2";
  pyproject = true;

  src = fetchPypi {
    pname = "blender_mcp";
    inherit version;
    hash = "sha256-lYvFCLArBiMIJ7nfSsmAnizD051quQRh/YYZDUsS8hc=";
  };

  build-system = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  dependencies = with python3.pkgs; [
    mcp
  ];

  pythonImportsCheck = [
    "blender_mcp"
  ];

  meta = {
    description = "Blender integration through the Model Context Protocol";
    homepage = "https://pypi.org/project/blender-mcp/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "blender-mcp";
  };
}
