#!/bin/bash

# 记录操作的功能
log_operation() {
    local operation_info
    operation_info="$(date +'%Y/%m/%d %H:%M:%S') $1 $2"
    if [ -f "Operation.txt" ]; then
        echo "$operation_info" >> "Operation.txt"
    else
        echo "$operation_info" > "Operation.txt"
    fi
}

# 如果不存在，则创建目录的功能
create_directory() {
    if [ ! -d "$1" ]; then
        mkdir -p "$1" || { echo "Error: Failed to create directory $1"; exit 1; }
        log_operation "Directory created:" "$1"
    fi
}

# 按创建日期移动照片的功能
move_photos_by_date() {
    local file creation_date destination_folder
    # 检查是否存在任何照片文件
    if compgen -G '*.jpg' >/dev/null || compgen -G '*.ARW' >/dev/null || compgen -G '*.NEF' >/dev/null || compgen -G '*.ORF' >/dev/null || compgen -G '*.RW2' >/dev/null || compgen -G '*.RAF' >/dev/null || compgen -G '*.DNG' >/dev/null; then
        shopt -s nocaseglob # Enable case-insensitive globbing
        for file in *.jpg *.ARW *.NEF *.ORF *.RW2 *.RAF *.DNG; do
            if [ -f "$file" ]; then
                creation_date=$(stat -f "%SB" -t "%Y-%m-%d" "$file" 2>/dev/null)
                if [ -n "$creation_date" ]; then
                    destination_folder="$creation_date"
                    create_directory "$destination_folder"
                    mv "$file" "$destination_folder/" || { echo "Error: Failed to move file $file"; exit 1; }
                    log_operation "File moved:" "$destination_folder/$file"
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

# 按文件格式移动照片的功能
move_photos_by_format() {
    local jpg_files arw_files
    jpg_files=(*.jpg *.JPG)
    arw_files=(*.ARW *.NEF *.ORF *.RW2 *.RAF *.DNG)
    if [ ${#jpg_files[@]} -gt 0 ] || [ ${#arw_files[@]} -gt 0 ]; then
        create_directory "JPG"
        create_directory "RAW"
        mv "${jpg_files[@]}" JPG/ 2>/dev/null
        mv "${arw_files[@]}" RAW/ 2>/dev/null
        log_operation "Photos moved by format."
        echo "Photos moved successfully by format."
    else
        echo "No photo files found."
    fi
}

# 撤销上次操作的功能
undo_last_operation() {
    if [ -f "Operation.txt" ]; then
        # 阅读Operation.txt的最后一行
        last_operation=$(tail -n 1 Operation.txt)
        # 提取操作类型和文件路径
        operation_type=$(echo "$last_operation" | awk '{print $2}')
        file_path=$(echo "$last_operation" | awk '{print $3}')
        # 根据操作类型执行撤销操作
        case $operation_type in
            "Directory created:")
                if [ -d "$file_path" ]; then
                    rm -r "$file_path" || { echo "Error: Failed to remove directory $file_path"; exit 1; }
                    echo "Undo operation successful: Removed directory $file_path"
                    # 从Operation.txt中删除最后一行
                    sed -i '$d' Operation.txt
                else
                    echo "Error: Directory $file_path not found."
                fi
                ;;
            "File moved:")
                if [ -f "$file_path" ]; then
                    mv "$file_path" . || { echo "Error: Failed to move file $file_path"; exit 1; }
                    echo "Undo operation successful: Moved file $file_path back"
                    # Remove last line from Operation.txt
                    sed -i '$d' Operation.txt
                else
                    echo "Error: File $file_path not found."
                fi
                ;;
            *)
                echo "Error: Unknown operation type."
                ;;
        esac
    else
        echo "No operation records found. Unable to undo."
    fi
}

# 主函数
main() {
    echo "Welcome to Photo Organizer!"
    echo "1. Organize photos by date"
    echo "2. Organize photos by format"
    echo "3. Undo the last operation"
    echo "4. Quit"
    read -p "Please select an option (1/2/3/4): " option
    case $option in
        1)
            move_photos_by_date
            ;;
        2)
            move_photos_by_format
            ;;
        3)
            undo_last_operation
            ;;
        4)
            echo "Exiting..."
            ;;
        *)
            echo "Invalid option. Please select again."
            ;;
    esac
}

# 调用主函数
main
