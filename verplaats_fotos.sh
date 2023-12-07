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

destination_dir="/nieuwe_fotos"  # Verander dit naar jouw gewenste doelmap
# Stelt de bestemmingsmap in op "/nieuwe_fotos".

# Controleer of de doelmap bestaat, anders maak deze aan
if [ ! -d "$destination_dir" ]; then
    if mkdir -p "$destination_dir"; then
        echo "Bestemmingsmap is aangemaakt: $destination_dir"
    else
        echo "Kan geen bestemmingsmap maken: $destination_dir"
        exit 1
    fi
fi
# Controleert of de doelmap bestaat. Zo niet, wordt deze gemaakt en wordt een bericht weergegeven; anders wordt een foutmelding weergegeven en wordt het script beëindigd met status 1.

# Functie om het week- of maandnummer uit de creatiedatum van het bestand te halen
get_date_number() {
    local file_date=$1
    local format=$2
    echo $(date -d "$file_date" +"$format")
}
# Definieert een functie 'get_date_number' om het week- of maandnummer uit een gegeven datum te halen.

# Loop door de map
for file in "$dir"/*
do
    if [ -f "$file" ]; then
        # Haal creatiedatum op
        creation_date=$(stat -c "%y" "$file" | awk '{print $1}') # Aanmaaktijd, verander %y naar %w voor geboortetijd
        
        # Haal week- of maandnummer op
        if [ "$option" == "week" ]; then
            date_number=$(get_date_number "$creation_date" "%V") # Weeknummer
        else
            date_number=$(get_date_number "$creation_date" "%m") # Maandnummer
        fi
        # Bepaalt het week- of maandnummer vanuit de aanmaakdatum van het bestand.

        # Maak een submap op basis van week- of maandnummer
        sub_dir="$destination_dir/$option$date_number"
        if [ ! -d "$sub_dir" ]; then
            if mkdir -p "$sub_dir"; then
                echo "Submap is aangemaakt: $sub_dir"
            else
                echo "Kan geen submap maken: $sub_dir"
                exit 1
            fi
        fi
        # Maakt een submap binnen de doelmap op basis van het week- of maandnummer.

        # Kopieer bestand naar de doelsubmap
        cp "$file" "$sub_dir"
        # Kopieert het bestand naar de doelsubmap.

        # Controleer md5sum
        original_hash=$(md5sum "$file" | awk '{print $1}')
        copied_hash=$(md5sum "$sub_dir/$(basename "$file")" | awk '{print $1}')
        # Berekent de MD5-hash van het originele bestand en het gekopieerde bestand.

        if [ "$original_hash" == "$copied_hash" ]; then
            # Verwijder het originele bestand als de kopie succesvol was
            rm "$file"
            echo "Bestand: $file is succesvol verplaatst naar $sub_dir"
        else
            echo "Fout bij kopiëren van $file naar $sub_dir. Hashes komen niet overeen."
        fi
        # Als de hashes overeenkomen, wordt het originele bestand verwijderd; anders wordt een foutmelding weergegeven.
    fi
done
# Doorloopt elk bestand in de opgegeven directory.
