mimetype="$(file --brief --dereference --mime-type $f)"

case "$mimetype" in
  text/*) lf -remote "send $id \$nvim $f" ;;
  *)      xdg-open $f >/dev/null 2>&1 & ;;
esac
