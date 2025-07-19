{
  writeShellScriptBin,
  openssh,
  ...
}:

let
  idFile = ./id_root;
in
writeShellScriptBin "microvm-ssh" ''
  ${openssh}/bin/ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ${idFile} root@localhost -p 2222
''
