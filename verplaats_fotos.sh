#!/bin/bash

echo "Hello"

dir=$1
option=$2

if [ "$option" != "week" ] && [ "$option" != "maand" ]; then
    echo "Geef een geldige tweede parameter: 'week' of 'maand'"
    exit 1
fi

if [ ! -d "$dir" ]; then
    echo "Voer een bestaande directory in"
    exit 1
fi

for file in "$dir"/*; do
    if [ -f "$file" ]; then
        if [[ "$file" == *.jpg || "$file" == *.png || "$file" == *.jpeg ]]; then
            filename=$(basename -- "$file")
            extension="${filename##*.}"
            filename="${filename%.*}"

            # Haal creatiedatum op
            if [[ "$OSTYPE" == "darwin"* ]]; then
                # macOS
                creation_date=$(stat -f "%Sm" -t "%Y-%m-%d" "$file")
            else
                # Linux
                creation_date=$(stat -c "%y" "$file" | awk '{print $1}')
            fi

            # Haal maand- of weeknummer op
            if [ "$option" == "week" ]; then
                date_number=$(date -d "$creation_date" +"%V") # Weeknummer
                new_dir="$dir/Week$date_number"
            else
                date_number=$(date -d "$creation_date" +"%m") # Maandnummer
                month_name=$(date -d "$creation_date" +"%B") # Maandnaam
                new_dir="$dir/Maand$month_name$date_number"
            fi

            # Maak een nieuwe map op basis van maand- of weeknummer
            if [ ! -d "$new_dir" ]; then
                if mkdir -p "$new_dir"; then
                    echo "Nieuwe map is aangemaakt: $new_dir"
                else
                    echo "Kan geen nieuwe map maken: $new_dir"
                    exit 1
                fi
            fi

            # Verplaats het foto bestand naar de nieuwe map
            mv "$file" "$new_dir/$filename.$extension"
            echo "Bestand: $file is succesvol verplaatst naar $new_dir"
        fi
    fi
done
