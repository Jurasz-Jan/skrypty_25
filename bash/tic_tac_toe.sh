#!/bin/bash

# Tic Tac Toe game
# Features:
# - turn-based play
# - save and load game state
# - play against another player or computer

SAVE_FILE="bash/savegame.txt"

# Print the board
print_board() {
    echo ""
    for i in {1..9}; do
        val=${board[$i]}
        if [ -z "$val" ]; then
            printf " %d " "$i"
        else
            printf " %s " "$val"
        fi
        if [ $((i % 3)) -ne 0 ]; then
            printf "|"
        fi
        if [ $((i % 3)) -eq 0 ] && [ $i -ne 9 ]; then
            echo -e "\n-----------"
        fi
    done
    echo -e "\n"
}

# Check for winner
check_winner() {
    combos=("1 2 3" "4 5 6" "7 8 9" "1 4 7" "2 5 8" "3 6 9" "1 5 9" "3 5 7")
    for combo in "${combos[@]}"; do
        set -- $combo
        a=${board[$1]}
        b=${board[$2]}
        c=${board[$3]}
        if [ -n "$a" ] && [ "$a" = "$b" ] && [ "$b" = "$c" ]; then
            echo "$a"
            return
        fi
    done
    # Check draw
    for i in {1..9}; do
        if [ -z "${board[$i]}" ]; then
            echo ""
            return
        fi
    done
    echo "draw"
}

# Save the game
save_game() {
    {
        for i in {1..9}; do
            echo "${board[$i]}"
        done
        echo "$current_player"
        echo "$game_mode"
    } > "$SAVE_FILE"
    echo "Game saved to $SAVE_FILE"
}

# Load the game
load_game() {
    if [ ! -f "$SAVE_FILE" ]; then
        echo "No saved game found." >&2
        return 1
    fi
    i=1
    while read -r line && [ $i -le 9 ]; do
        board[$i]="$line"
        i=$((i+1))
    done < "$SAVE_FILE"
    read -r current_player < <(sed -n '10p' "$SAVE_FILE")
    read -r game_mode < <(sed -n '11p' "$SAVE_FILE")
    echo "Loaded saved game."
}

# Simple AI move: pick random empty cell
ai_move() {
    empty_cells=()
    for i in {1..9}; do
        if [ -z "${board[$i]}" ]; then
            empty_cells+=("$i")
        fi
    done
    if [ ${#empty_cells[@]} -gt 0 ]; then
        rand_index=$((RANDOM % ${#empty_cells[@]}))
        choice=${empty_cells[$rand_index]}
        board[$choice]="$current_player"
        echo "Computer chose: $choice"
    fi
}

# Initialize new game
new_game() {
    for i in {1..9}; do
        board[$i]=""
    done
    current_player="X"
}

play_game() {
    while true; do
        print_board
        winner=$(check_winner)
        if [ -n "$winner" ]; then
            if [ "$winner" = "draw" ]; then
                echo "It's a draw!"
            else
                echo "Player $winner wins!"
            fi
            rm -f "$SAVE_FILE"
            break
        fi

        if [ "$game_mode" = "computer" ] && [ "$current_player" = "O" ]; then
            ai_move
        else
            read -p "Player $current_player, choose a field (1-9) or 's' to save and exit: " choice
            if [ "$choice" = "s" ]; then
                save_game
                break
            fi
            if [[ ! "$choice" =~ ^[1-9]$ ]]; then
                echo "Invalid choice."
                continue
            fi
            if [ -n "${board[$choice]}" ]; then
                echo "Field already taken."
                continue
            fi
            board[$choice]="$current_player"
        fi

        if [ "$current_player" = "X" ]; then
            current_player="O"
        else
            current_player="X"
        fi
    done
}

# Start script
echo "Tic Tac Toe"
if [ -f "$SAVE_FILE" ]; then
    read -p "Load saved game? (y/n): " load
    if [ "$load" = "y" ]; then
        load_game || new_game
    else
        new_game
    fi
else
    new_game
fi

read -p "Play against computer? (y/n): " vs
if [ "$vs" = "y" ]; then
    game_mode="computer"
else
    game_mode="human"
fi

play_game

