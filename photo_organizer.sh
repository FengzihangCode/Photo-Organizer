#!/bin/bash

# Function to create directory if not exists
create_directory() {
    if [ ! -d "$1" ]; then
        mkdir -p "$1" || { echo "Error: Failed to create directory $1"; exit 1; }
    fi
}

# Function to move photos by creation date
move_photos_by_date() {
    local file creation_date destination_folder
    # Check if any photo files exist
    if compgen -G '*.jpg' >/dev/null || compgen -G '*.ARW' >/dev/null || compgen -G '*.NEF' >/dev/null || compgen -G '*.ORF' >/dev/null || compgen -G '*.RW2' >/dev/null || compgen -G '*.RAF' >/dev/null || compgen -G '*.DNG' >/dev/null; then
        shopt -s nocaseglob # Enable case-insensitive globbing
        for file in *.jpg *.ARW *.NEF *.ORF *.RW2 *.RAF *.DNG; do
            if [ -f "$file" ]; then
                creation_date=$(stat -f "%SB" -t "%Y-%m-%d" "$file" 2>/dev/null)
                if [ -n "$creation_date" ]; then
                    destination_folder="$creation_date"
                    create_directory "$destination_folder"
                    mv "$file" "$destination_folder/" || { echo "Error: Failed to move file $file"; exit 1; }
                else
                    echo "Failed to get creation date for file: $file"
                fi
            fi
        done
        shopt -u nocaseglob # Disable case-insensitive globbing
        echo "Photos moved successfully by date."
    else
        echo "No photo files found."
    fi
}

# Function to move photos by file format
move_photos_by_format() {
    local jpg_files arw_files
    jpg_files=(*.jpg *.JPG)
    arw_files=(*.ARW *.NEF *.ORF *.RW2 *.RAF *.DNG)
    if [ ${#jpg_files[@]} -gt 0 ] || [ ${#arw_files[@]} -gt 0 ]; then
        create_directory "JPG"
        create_directory "RAW"
        mv "${jpg_files[@]}" JPG/ 2>/dev/null
        mv "${arw_files[@]}" RAW/ 2>/dev/null
        echo "Photos moved successfully by format."
    else
        echo "No photo files found."
    fi
}

# Main function
main() {
    echo "Welcome to Photo Organizer!"
    echo "1. Organize photos by date"
    echo "2. Organize photos by format"
    echo "3. Quit"
    read -p "Please select an option (1/2/3): " option
    case $option in
        1)
            move_photos_by_date
            ;;
        2)
            move_photos_by_format
            ;;
        3)
            echo "Exiting..."
            ;;
        *)
            echo "Invalid option. Please select again."
            ;;
    esac
}

# Call the main function
main
