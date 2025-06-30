# change directory with fzf
# Usage: cdf [optional_relative_path]
#   - If no argument, searches from $HOME.
#   - If a relative path (e.g., "projects/my_app") is provided, searches only within that path relative to $HOME.
#   - If an absolute path (e.g., "/mnt/data") is provided, searches only within that path.
function cdf() {
  local exclude_names=(
    ".cache" 
    ".cargo" 
    ".git" 
    ".npm" 
    ".rustup" 
    ".venv" 
    "Library" 
    "__pycache__" 
    "build" 
    "cache" 
    "dist" 
    "neorv32"
    "nixpkgs"
    "node_modules" 
    "octave"
    "snap" 
    "target" 
    "venv" 
  )

  local dir="$HOME"

  if [[ -n "$1" ]]; then
    if [[ "$1" == /* ]]; then
      dir="$1"
    else
      dir="$HOME/$1"
    fi

    if [[ ! -d "$dir" ]]; then
      echo "Error: '$dir' does not exist or is not a directory."
      return 1
    fi
  fi
  
  local find_args=("$dir")
  find_args+=(-path "$dir/.*" -prune -o)
  
  local prune_exprs=()
  local has_prunes=false
  for name in "${exclude_names[@]}"; do
    if $has_prunes; then
      prune_exprs+=(-o)
    fi
    prune_exprs+=(-name "$name")
    has_prunes=true
  done
  
  if $has_prunes; then
    find_args+=(\( "${prune_exprs[@]}" \) -prune -o)
  fi
  
  find_args+=(-type d -print)
  
  local fzf_args=(
    "-i"
    "--height=40%"
    "--reverse"
    "--prompt=Select directory: "
    "--preview=tree -C {} | head -50"
    "--preview-window=right:50%:wrap"
  )
  local selected=$(find "${find_args[@]}" 2>/dev/null | fzf "${fzf_args[@]}")
  
  if [[ -n "$selected" ]]; then
    cd "$selected" || echo "Failed to cd into '$selected'"
    pwd
    ls -lAh
  fi
}
