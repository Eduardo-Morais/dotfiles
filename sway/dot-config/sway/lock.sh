#!/bin/bash
# GNOME-style Lock Screen using GTKLock with fast blur & seamless suspend support

# Se o gtklock já estiver em execução, evita rodar outra instância
if pgrep -xu "$USER" gtklock >/dev/null; then
    if [ "$1" = "--suspend" ]; then
        systemctl suspend
    fi
    exit 0
fi

IMAGE="/tmp/gtklock_screen.png"

# Captura a tela atual e aplica o desfoque estilo GNOME de forma ultrarrápida em memória
if command -v grim >/dev/null 2>&1 && command -v magick >/dev/null 2>&1; then
    grim - 2>/dev/null | magick - -scale 5% -resize 2000% "$IMAGE" 2>/dev/null
elif command -v grim >/dev/null 2>&1 && command -v convert >/dev/null 2>&1; then
    grim - 2>/dev/null | convert - -scale 5% -resize 2000% "$IMAGE" 2>/dev/null
fi

EXTRA_ARGS=("-d")

if [ "$1" = "--suspend" ]; then
    EXTRA_ARGS+=("-L" "systemctl suspend")
fi

EXTRA_ARGS+=("-U" "rm -f $IMAGE")

BG_ARGS=()
if [ -s "$IMAGE" ]; then
    BG_ARGS=("-b" "$IMAGE")
fi

if command -v gtklock >/dev/null 2>&1; then
    gtklock "${BG_ARGS[@]}" -s "$HOME/.config/gtklock/style.css" -t "%H:%M" -D "%A, %d de %B" "${EXTRA_ARGS[@]}"
else
    swaylock -f -i "$IMAGE" --scaling fill
    if [ "$1" = "--suspend" ]; then
        systemctl suspend
    fi
fi
