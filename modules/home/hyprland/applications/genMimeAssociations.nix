# Generate a list of mime associations for a desktop file
desktop: mimeTypes:
builtins.listToAttrs (
  map (mimeType: {
    name = mimeType;
    value = desktop;
  }) mimeTypes
)
