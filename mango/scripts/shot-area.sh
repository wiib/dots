#!/usr/bin/env bash

# shot-area.sh
# Parameters: screen, area, client

# Constants
NOTIF_APP='grim+slurp'

MODE=${1:-area}
FILENAME=~/Pictures/Screenshot_$(date +%Y-%m-%d_%H-%M-%S).png

# Selection geometry
geometry=""

case "$MODE" in
    'screen')
        NOTIF_MSG="Screen copied and saved to $FILENAME."
        ;;
    'area')
        geometry=$(slurp)

        # Check for selection cancel
        if [[ $? -ne 0 ]]; then
            notify-send -a "$NOTIF_APP" "Screenshot cancelled" "Area selection was cancelled by user."
            exit 0
        fi

        # Check for invalid selection
        if [[ -z "$geometry" ]]; then
            notify-send -a "$NOTIF_APP" "Invalid geometry" "Selected area was invalid."
            exit 1
        fi

        NOTIF_MSG="Area copied and saved to $FILENAME."
        ;;
    'client')
        IPC_OUTPUT=$(mmsg -x)

        # Parse mmsg output
        geometry=$(echo "$IPC_OUTPUT" | awk '
            $(NF-1)=="x"        {x=$NF}
            $(NF-1)=="y"        {y=$NF}
            $(NF-1)=="width"    {w=$NF}
            $(NF-1)=="height"   {h=$NF}

            END {
                if (x!="" && y!="" && w!="" && h!="")
                    printf "%s,%s %sx%s", x, y, w, h
            }
        ')

        if [[ -z $geometry ]]; then
            notify-send -a "$NOTIF_APP" "Invalid geometry" "Geometry obtained from IPC was invalid."
        fi

        NOTIF_MSG="Active client copied and saved to $FILENAME."
        ;;
    *)
        notify-send -a "$NOTIF_APP" "Invalid mode" "Invalid screenshot mode: $MODE."
        exit 1
        ;;
esac

# Take screenshot
grim ${geometry:+-g "$geometry"} - | tee "$FILENAME" | wl-copy
notify-send -a "$NOTIF_APP" "$NOTIF_MSG" -i $FILENAME

