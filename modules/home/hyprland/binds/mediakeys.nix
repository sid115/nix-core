{ pkgs, ... }:

let
  brightness = "${pkgs.brightnessctl}/bin/brightnessctl";
  player = "${pkgs.playerctl}/bin/playerctl";
  volume = "${pkgs.pulseaudio}/bin/pactl";
in
[
  ",      XF86MonBrightnessUp,   exec, ${brightness} s +5%" # increase screen brightness
  ",      XF86MonBrightnessDown, exec, ${brightness} s 5%-" # decrease screen brightness
  ",      XF86AudioRaiseVolume,  exec, ${volume} set-sink-volume 0 +5%" # raise speaker volume
  ",      XF86AudioLowerVolume,  exec, ${volume} set-sink-volume 0 -5%" # lower speaker volume
  "SHIFT, XF86AudioRaiseVolume,  exec, ${volume} set-source-volume 0 +1%" # raise mic volume
  "SHIFT, XF86AudioLowerVolume,  exec, ${volume} set-source-volume 0 -1%" # lower mic volume
  ",      XF86AudioMute,         exec, ${volume} set-sink-mute 0 toggle" # mute/unmute speaker
  "SHIFT, XF86AudioMute,         exec, ${volume} set-source-mute 0 toggle" # mute/unmute mic
  ",      XF86AudioMicMute,      exec, ${volume} set-source-mute 0 toggle" # mute/unmute mic
  ",      XF86AudioPlay,         exec, ${player} play-pause" # toggle between play and pause music
  ",      XF86AudioStop,         exec, ${player} stop" # stop music
  ",      XF86AudioPrev,         exec, ${player} previous" # play previous
  ",      XF86AudioNext,         exec, ${player} next" # play next
]
