{
  writeShellApplication,
  jq,
  ...
}:

let
  name = "deploy";
  text = builtins.readFile ./${name}.sh;
in
writeShellApplication {
  inherit name text;
  meta.mainProgram = name;

  runtimeInputs = [
    jq
  ];
}
