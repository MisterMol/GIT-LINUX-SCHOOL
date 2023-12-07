#!/bin/bash

source_dir=$1  # Map waar de foto's zich bevinden
option=$2      # Optie: "maand" of "week"

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
    local photos=$(find "$1" -type d -name "random fotos*" -print)
    local target_dir="$2"
    
    for photo in "$photos"/*; do
        if [ -f "$photo" ]; then
            case "$option" in
                "week")
                    week_number=$(get_week_number)
                    destination="${target_dir}/week_${week_number}"
                    ;;
                "maand")
                    month_number=$(get_month_number)
                    destination="${target_dir}/maand_${month_number}"
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

# Controleer of de directory bestaat
if [ ! -d "$source_dir" ]; then
    echo "Ongeldige directory. Voer een geldige directory in."
    exit 1
fi

# Roep de functie aan om foto's te verplaatsen
move_photos "$source_dir" "/pad/naar/doelmap"  # Vervang "/pad/naar/doelmap" door de gewenste doelmap
