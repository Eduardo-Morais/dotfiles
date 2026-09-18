#!/bin/bash
# GNOME-style Lock Screen using GTKLock with fast blur & seamless suspend support

SUSPEND=0
if [ "$1" = "--suspend" ]; then
    SUSPEND=1
fi

# Se o gtklock ou swaylock já estiver em execução, evita rodar outra instância
if pgrep -xu "$USER" gtklock >/dev/null || pgrep -xu "$USER" swaylock >/dev/null; then
    if [ "$SUSPEND" -eq 1 ]; then
        swaymsg "output * power off"
        sleep 0.3
        systemctl suspend
        swaymsg "output * power on"
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

EXTRA_ARGS=("-d" "-U" "rm -f $IMAGE")

BG_ARGS=()
if [ -s "$IMAGE" ]; then
    BG_ARGS=("-b" "$IMAGE")
fi

if command -v gtklock >/dev/null 2>&1; then
    gtklock "${BG_ARGS[@]}" -s "$HOME/.config/gtklock/style.css" -t "%H:%M" -D "%A, %d de %B" "${EXTRA_ARGS[@]}"
else
    swaylock -f -i "$IMAGE" --scaling fill
fi

# Aguarda o processo de bloqueio se registrar e o compositor estabilizar o frame antes de suspender
for i in {1..10}; do
    if pgrep -xu "$USER" gtklock >/dev/null || pgrep -xu "$USER" swaylock >/dev/null; then
        break
    fi
    sleep 0.05
done

if [ "$SUSPEND" -eq 1 ]; then
    # Breve pausa para o gtklock aparecer suavemente na tela antes de apagar
    sleep 0.5
    swaymsg "output * power off"
    sleep 0.3
    systemctl suspend
    swaymsg "output * power on"
fi
