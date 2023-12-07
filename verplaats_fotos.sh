#!/bin/bash

source_dir=$(dirname "$0")  # De map waarin het script zich bevindt
option=$1                   # Optie: "maand" of "week"
target_dir="Nieuwe_Fotos"   # Naam van de doelmap

# Functie om het weeknummer te verkrijgen
get_week_number() {
    date +"%V"
}

# Functie om het maandnummer te verkrijgen
get_month_number() {
    date +"%m"
}

# Functie om foto's naar overeenkomstige mappen te verplaatsen op basis van de gekozen optie
move_photos() {
    local photos=$(find "$1/random fotos" -type f)
    local target="$2"

    for photo in $photos; do
        if [ -f "$photo" ]; then
            case "$option" in
                "week")
                    week_number=$(get_week_number)
                    destination="${target}/${week_number}"
                    ;;
                "maand")
                    month_number=$(get_month_number)
                    destination="${target}/${month_number}"
                    ;;
                *)
                    echo "Ongeldige optie. Kies 'maand' of 'week'."
                    exit 1
                    ;;
            esac

            mkdir -p "$destination"  # Maak de doelmap aan als deze niet bestaat
            cp "$photo" "$destination"  # Kopieer de foto naar de bestemming
            
            # Controleer of de kopie succesvol was door middel van de MD5-hash
            if diff -q <(md5sum "$photo") <(md5sum "${destination}/$(basename "$photo")") >/dev/null; then
                rm "$photo"  # Verwijder de originele foto als de kopie succesvol was
            else
                echo "Fout bij kopiëren van foto: $(basename "$photo")"
            fi
        fi
    done
}

# Roep de functie aan om foto's te verplaatsen
move_photos "$source_dir" "$target_dir"
