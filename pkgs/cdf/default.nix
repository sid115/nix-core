{
  writeShellScriptBin,
  symlinkJoin,
  makeWrapper,

  bash,
  coreutils,
  fzf,
  tree,
  ...
}:

let
  cdf = writeShellScriptBin "cdf" (builtins.readFile ./cdf.sh);
in
symlinkJoin rec {
  name = "cdf";

  buildInputs = [ makeWrapper ];

  paths = [
    bash
    cdf
    coreutils
    fzf
    tree
  ];

  postBuild = "wrapProgram $out/bin/${name} --prefix PATH : $out/bin";
}
