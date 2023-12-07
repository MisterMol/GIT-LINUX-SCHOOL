#!/bin/bash

source_dir=$(dirname "$0")  # De map waarin het script zich bevindt
target_dir="${source_dir}/Nieuwe_Fotos"   # Pad naar de doelmap

# Functie om foto's naar overeenkomstige mappen te verplaatsen op basis van de gekozen optie
move_photos() {
    local option="$1"
    local photos=$(find "${source_dir}/random fotos" -type f)
    local target="$2"

    for photo in $photos; do
        if [ -f "$photo" ]; then
            case "$option" in
                "week")
                    week_number=$(date +"%V")
                    new_name="${target}/week_${week_number}_$(basename "$photo")"
                    ;;
                "maand")
                    month_number=$(date +"%m")
                    new_name="${target}/maand_${month_number}_$(basename "$photo")"
                    ;;
                *)
                    echo "Ongeldige optie. Kies 'maand' of 'week'."
                    exit 1
                    ;;
            esac

            mkdir -p "$target"  # Maak de doelmap aan als deze niet bestaat
            mv "$photo" "$new_name"  # Verplaats de foto naar de bestemming met nieuwe naam
            echo "Foto '$(basename "$photo")' succesvol verplaatst naar '${new_name}'"
        fi
    done
}

# Vraag de gebruiker om invoer van 'maand' of 'week'
read -p "Voer 'maand' of 'week' in voor het verplaatsen van de foto's: " user_option

# Roep de functie aan om foto's te verplaatsen
move_photos "$user_option" "$target_dir"
