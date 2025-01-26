# custom/newsboat
{
  lib,
  pkgs,
  ...
}:

let
  newsboat-print-unread =
    let
      newsboat = "${pkgs.newsboat}/bin/newsboat";
    in
    (pkgs.writeShellScriptBin "newsboat-print-unread" ''
      UNREAD=$(${newsboat} -x print-unread | awk '{print $1}')

      if [[ $UNREAD -gt 0 ]]; then
      	printf " %i" "$UNREAD"
      fi
    '');

  inherit (lib) mkDefault;
in
{
  exec = mkDefault "${newsboat-print-unread}/bin/newsboat-print-unread";
  format = mkDefault "{}";
  hide-empty-text = mkDefault true; # disable module when output is empty
  signal = mkDefault 10;
  on-click = mkDefault "newsboat-reload";
}
