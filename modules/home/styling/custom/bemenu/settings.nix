{ config, ... }:

let
  colors = config.lib.stylix.colors.withHashtag;
  radius = config.styling.radius;
in
{
  border-radius = radius;

  bdr = colors.blue; # Border
  tb = colors.base00; # Title background
  tf = colors.green; # Title foreground
  fb = colors.base00; # Filter background
  ff = colors.base05; # Filter foreground
  cb = colors.base00; # Cursor background
  cf = colors.base02; # Cursor foreground
  nb = colors.base00; # Normal background
  nf = colors.base05; # Normal foreground
  hb = colors.base01; # Highlighted background
  hf = colors.blue; # Highlighted foreground
  fbb = colors.base00; # Feedback background
  fbf = colors.base05; # Feedback foreground
  sb = colors.base01; # Selected background
  sf = colors.base05; # Selected foreground
  ab = colors.base00; # Alternating background
  af = colors.base05; # Alternating foreground
  scb = colors.base00; # Scrollbar background
  scf = colors.blue; # Scrollbar foreground
}
