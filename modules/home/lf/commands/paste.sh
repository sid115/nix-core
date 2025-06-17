set -- $(cat ~/.local/share/lf/files)
mode="$1"
shift
case "$mode" in
    copy)
        rsync -av --ignore-existing --progress -- "$@" . |
        stdbuf -i0 -o0 -e0 tr '\r' '\n' |
        while IFS= read -r line; do
            line="$(printf '%s' "$line" | sed 's/\\/\\\\/g;s/"/\\"/g')"
            lf -remote "send $id echo \"$line\""
        done
        ;;
    move) mv -n -- "$@" .;;
esac
rm ~/.local/share/lf/files
lf -remote "send clear"
