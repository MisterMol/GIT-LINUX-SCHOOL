#!/bin/bash
# De shebang-lijn specificeert de interpreter om het script uit te voeren.

echo "Hello"
# Toont "Hello" op de console.

dir=$1 # Bewaar de map van het scriptparameter in een variabele
option=$2 # Bewaar de optie (week/maand) van het scriptparameter in een variabele
# Wijs het eerste en tweede commandoregelargument toe aan variabelen 'dir' en 'option'.

if [ "$option" != "week" ] && [ "$option" != "maand" ]; then
    echo "Geef een geldige tweede parameter: 'week' of 'maand'"
    exit 1
fi
# Controleert of de tweede parameter 'week' of 'maand' is. Zo niet, wordt een foutmelding weergegeven en wordt het script beëindigd met status 1.

if [ ! -d "$dir" ]; then
    echo "Voer een bestaande directory in"
    exit 1
fi
# Controleert of de opgegeven directory bestaat. Zo niet, wordt een foutmelding weergegeven en wordt het script beëindigd met status 1.

# Loop door de map
for file in "$dir"/*
do
    if [ -f "$file" ]; then
        # Controleer of het een foto bestand is (extensies zoals .jpg, .png, .jpeg, etc.)
        if [[ "$file" == *.jpg || "$file" == *.png || "$file" == *.jpeg ]]; then
            # Haal alleen de bestandsnaam zonder het pad op
            filename=$(basename -- "$file")
        
            # Haal de extensie van het bestand op
            extension="${filename##*.}"
            
            # Haal de bestandsnaam zonder de extensie op
            filename="${filename%.*}"

            # Haal creatiedatum op
            creation_date=$(stat -c "%y" "$file" | awk '{print $1}') # Aanmaaktijd, verander %y naar %w voor geboortetijd

            # Haal week- of maandnummer op
            if [ "$option" == "week" ]; then
                date_number=$(date -d "$creation_date" +"%V") # Weeknummer
            else
                date_number=$(date -d "$creation_date" +"%m") # Maandnummer
            fi

            # Maak een nieuwe map op basis van week- of maandnummer
            new_dir="$dir/$option$date_number"
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
# Doorloopt elk bestand in de opgegeven directory.
