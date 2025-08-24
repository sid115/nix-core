#!/bin/bash

if [ -n "$XDG_DOCUMENTS_DIR" ]; then
    NOTES_DIR="$XDG_DOCUMENTS_DIR/notes"
else
    NOTES_DIR="/tmp/notes"
fi

mkdir -p "$NOTES_DIR"

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
NOTE_FILE="$NOTES_DIR/note_$TIMESTAMP.md"
touch "$NOTE_FILE"

if [ -z "$EDITOR" ]; then
    # Try common editors
    for editor in vim vi nano; do
        if command -v "$editor" &> /dev/null; then
            EDITOR="$editor"
            break
        fi
    done
    
    if [ -z "$EDITOR" ]; then
        echo "Error: No editor found. Please set the EDITOR environment variable."
        exit 1
    fi
fi

"$EDITOR" "$NOTE_FILE"
