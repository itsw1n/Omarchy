-- Personal overrides on top of Omarchy's quattro defaults.

-- OpenCode instead of Calendar; Typora instead of Omawrite.
o.bind("SUPER + SHIFT + C", "OpenCode", { tui = "opencode" })
o.bind("SUPER + SHIFT + W", "Typora", "uwsm-app -- typora --enable-wayland-ime")

-- Display: SUPER+P is the Win+P mode menu; pseudo moves to SUPER+CTRL+P.
hl.unbind("SUPER + P")
o.bind("SUPER + P", "Display mode", "omarchy hook display-mode-menu")
o.bind("SUPER + CTRL + P", "Pseudo window", hl.dsp.window.pseudo())

-- Send the focused window to the TV workspace and bring it back.
o.bind("SUPER + ALT + P", "Send to TV (ws 3)", "~/.config/hypr/scripts/send-to-tv.sh")
o.bind("SUPER + ALT + SHIFT + P", "Bring back from TV", "~/.config/hypr/scripts/bring-from-tv.sh")

-- Next wallpaper.
hl.unbind("SUPER + CTRL + SPACE")
o.bind("SUPER + CTRL + SPACE", "Next wallpaper", "omarchy-theme-bg-next")
