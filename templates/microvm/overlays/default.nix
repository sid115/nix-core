{ inputs, ... }:

{
  core-packages = final: prev: { core = inputs.core.overlays.additions final prev; };

  local-packages = final: prev: { local = import ../pkgs { pkgs = final; }; };
}
