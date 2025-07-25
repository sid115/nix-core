{
  writeShellApplication,
  jq,
  nix-update,
  ...
}:

let
  name = "update-packages";
  text = builtins.readFile ./${name}.sh;
in
writeShellApplication {
  inherit name text;
  meta.mainProgram = name;

  runtimeInputs = [
    jq
    nix-update
  ];
}
