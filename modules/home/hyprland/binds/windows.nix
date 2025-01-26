[
  "$mod SHIFT, c,      killactive" # kill active window
  "$mod SHIFT, Return, layoutmsg, swapwithmaster master" # make active window master
  "$mod CTRL,  Return, layoutmsg, focusmaster" # focus master
  "$mod,       j,      layoutmsg, cyclenext" # focus next window
  "$mod,       k,      layoutmsg, cycleprev" # focus previous window
  "$mod SHIFT, j,      layoutmsg, swapnext" # swaps window with next
  "$mod SHIFT, k,      layoutmsg, swapprev" # swaps window with previous
  "$mod,       h,      splitratio, -0.05" # decrease horizontal space of master stack
  "$mod,       l,      splitratio, +0.05" # increase horizontal space of master stack
  "$mod SHIFT, h,      resizeactive, 0 -40" # shrink active window vertically
  "$mod SHIFT, l,      resizeactive, 0 40" # expand active window vertically
  "$mod,       i,      layoutmsg, addmaster" # add active window to master stack
  "$mod SHIFT, i,      layoutmsg, removemaster" # remove active window from master stack
  "$mod,       o,      layoutmsg, orientationcycle left top" # toggle between left and top orientation
  "$mod,       left,   movefocus, l" # focus window to the left
  "$mod,       right,  movefocus, r" # focus window to the right
  "$mod,       up,     movefocus, u" # focus upper window
  "$mod,       down,   movefocus, d" # focus lower window
  "$mod SHIFT, left,   swapwindow, l" # swap active window with window to the left
  "$mod SHIFT, right,  swapwindow, r" # swap active window with window to the right
  "$mod SHIFT, up,     swapwindow, u" # swap active window with upper window
  "$mod SHIFT, down,   swapwindow, d" # swap active window with lower window
  "$mod,       f,      togglefloating" # toggle floating for active window
  "$mod CTRL,  f,      workspaceopt, allfloat" # toggle floating for all windows on workspace
  "$mod SHIFT, f,      fullscreen" # toggle fullscreen for active window
]
