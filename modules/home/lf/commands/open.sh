# FIXME: kitty and nvim are hardcoded
fromSpecialWS="$(hyprctl monitors -j | jq 'any(.specialWorkspace.name == "special:lf")')"
mimetype="$(file --brief --dereference --mime-type $f)"

# Prioritize editor for text files when opening from lf
if [[ "$fromSpecialWS" == "true" ]]; then
  hyprctl dispatch togglespecialworkspace lf
  case "$mimetype" in
    text/*) kitty -e nvim $f ;;
    *)      xdg-open $f >/dev/null 2>&1 & ;;
  esac
else
  case "$mimetype" in
    text/*) lf -remote "send $id \$nvim $f" ;;
    *)      xdg-open $f >/dev/null 2>&1 & ;;
  esac
fi
