#!/bin/bash

echo "Hello"

dir=$1 # Store directory from script parameter in variable

if [ ! -d "$dir" ]; then
    echo "Voer een bestaande directory in"
    exit 1
fi

# Loop through directory
for file in "$dir"/*
do
    if [ -f "$file" ]; then
        # Make directory (if not exists)
        destination_dir="/nieuwe_fotos"  # Change this to your desired destination folder
        mkdir -p "$destination_dir"  # -p flag creates parent directories if they don't exist
        
        # Copy file to destination
        cp "$file" "$destination_dir"
        
        # Get creation date
        creationdate=$(stat -c "%y" "$file" | awk '{print $1}') # Modification time, change %y to %w for birth time
        
        # Check md5sum
        originalhash=$(md5sum "$file" | awk '{print $1}')

        echo "File: $file, Creation Date: $creationdate, MD5 Hash: $originalhash"
    fi
done
