#!/bin/bash

echo "Hello"

dir=$1 # Store directory from script parameter in variable
option=$2 # Store option (week/month) from script parameter in variable

if [ "$option" != "week" ] && [ "$option" != "maand" ]; then
    echo "Geef een geldige tweede parameter: 'week' of 'maand'"
    exit 1
fi

if [ ! -d "$dir" ]; then
    echo "Voer een bestaande directory in"
    exit 1
fi

destination_dir="/nieuwe_fotos"  # Change this to your desired destination folder

# Check if destination directory exists or create it
if [ ! -d "$destination_dir" ]; then
    if mkdir -p "$destination_dir"; then
        echo "Bestemmingsmap is aangemaakt: $destination_dir"
    else
        echo "Kan geen bestemmingsmap maken: $destination_dir"
        exit 1
    fi
fi

# Function to get the week or month number from the file creation date
get_date_number() {
    local file_date=$1
    local format=$2
    echo $(date -d "$file_date" +"$format")
}

# Loop through directory
for file in "$dir"/*
do
    if [ -f "$file" ]; then
        # Get creation date
        creation_date=$(stat -c "%y" "$file" | awk '{print $1}') # Modification time, change %y to %w for birth time
        
        # Get week or month number
        if [ "$option" == "week" ]; then
            date_number=$(get_date_number "$creation_date" "%V") # Week number
        else
            date_number=$(get_date_number "$creation_date" "%m") # Month number
        fi
        
        # Create subdirectory based on week or month number
        sub_dir="$destination_dir/$option$date_number"
        if [ ! -d "$sub_dir" ]; then
            if mkdir -p "$sub_dir"; then
                echo "Submap is aangemaakt: $sub_dir"
            else
                echo "Kan geen submap maken: $sub_dir"
                exit 1
            fi
        fi
        
        # Copy file to destination subdirectory
        cp "$file" "$sub_dir"
        
        # Check md5sum
        original_hash=$(md5sum "$file" | awk '{print $1}')
        copied_hash=$(md5sum "$sub_dir/$(basename "$file")" | awk '{print $1}')
        
        if [ "$original_hash" == "$copied_hash" ]; then
            # Remove original file if copy was successful
            rm "$file"
            echo "File: $file is succesvol verplaatst naar $sub_dir"
        else
            echo "Fout bij kopiëren van $file naar $sub_dir. Hashes komen niet overeen."
        fi
    fi
done
