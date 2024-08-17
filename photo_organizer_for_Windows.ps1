# 记录操作的功能
function Log-Operation {
    param (
        [string]$operation
    )
    $operationInfo = "$(Get-Date -Format 'yyyy/MM/dd HH:mm:ss') $operation"
    if (Test-Path -Path "Operation.txt") {
        Add-Content -Path "Operation.txt" -Value $operationInfo
    } else {
        Set-Content -Path "Operation.txt" -Value $operationInfo
    }
}

# 如果不存在，则创建目录
function Create-Directory {
    param (
        [string]$path
    )
    if (-not (Test-Path -Path $path -PathType Container)) {
        New-Item -Path $path -ItemType Directory | Out-Null
        Log-Operation "Directory created: $path"
    }
}

# 按创建日期移动照片的功能
function Move-PhotosByDate {
    $photoFiles = Get-ChildItem -File -Filter *.jpg,*.ARW,*.NEF,*.ORF,*.RW2,*.RAF,*.DNG
    if ($photoFiles.Count -gt 0) {
        foreach ($file in $photoFiles) {
            $creationDate = $file.LastWriteTime.ToString("yyyy-MM-dd")
            $destinationFolder = Join-Path -Path $creationDate -ChildPath $file.Name
            Create-Directory -path $creationDate
            Move-Item -Path $file.FullName -Destination $destinationFolder -ErrorAction SilentlyContinue
            Log-Operation "File moved: $destinationFolder\$($file.Name)"
        }
        Write-Output "Photos moved successfully by date."
    } else {
        Write-Output "No photo files found."
    }
}

# 按文件格式移动照片的功能
function Move-PhotosByFormat {
    $jpgFiles = Get-ChildItem -File -Filter *.jpg
    $rawFiles = Get-ChildItem -File -Filter *.ARW,*.NEF,*.ORF,*.RW2,*.RAF,*.DNG
    if ($jpgFiles.Count -gt 0 -or $rawFiles.Count -gt 0) {
        Create-Directory -path "JPG"
        Create-Directory -path "RAW"
        Move-Item -Path $jpgFiles.FullName -Destination "JPG" -ErrorAction SilentlyContinue
        Move-Item -Path $rawFiles.FullName -Destination "RAW" -ErrorAction SilentlyContinue
        Log-Operation "Photos moved by format."
        Write-Output "Photos moved successfully by format."
    } else {
        Write-Output "No photo files found."
    }
}

# 撤销上次操作的功能
function Undo-LastOperation {
    if (Test-Path -Path "Operation.txt") {
        $lastOperation = Get-Content -Path "Operation.txt" | Select-Object -Last 1
        $operationType = ($lastOperation -split ' ')[1]
        $filePath = ($lastOperation -split ' ')[2]
        switch ($operationType) {
            "Directory" {
                if (Test-Path -Path $filePath -PathType Container) {
                    Remove-Item -Path $filePath -Recurse -Force
                    Write-Output "Undo operation successful: Removed directory $filePath"
                    (Get-Content "Operation.txt") | Select-Object -First ((Get-Content "Operation.txt").Count - 1) | Set-Content "Operation.txt"
                } else {
                    Write-Output "Error: Directory $filePath not found."
                }
            }
            "File" {
                if (Test-Path -Path $filePath -PathType Leaf) {
                    Move-Item -Path $filePath -Destination "." -ErrorAction SilentlyContinue
                    Write-Output "Undo operation successful: Moved file $filePath back"
                    (Get-Content "Operation.txt") | Select-Object -First ((Get-Content "Operation.txt").Count - 1) | Set-Content "Operation.txt"
                } else {
                    Write-Output "Error: File $filePath not found."
                }
            }
            default {
                Write-Output "Error: Unknown operation type."
            }
        }
    } else {
        Write-Output "No operation records found. Unable to undo."
    }
}

# 主函数
function Main {
    Write-Output "Welcome to Photo Organizer!"
    Write-Output "1. Organize photos by date"
    Write-Output "2. Organize photos by format"
    Write-Output "3. Undo last operation"
    Write-Output "4. Quit"
    $option = Read-Host "Please select an option (1/2/3/4)"
    switch ($option) {
        1 { Move-PhotosByDate }
        2 { Move-PhotosByFormat }
        3 { Undo-LastOperation }
        4 { Write-Output "Exiting..." }
        default { Write-Output "Invalid option. Please select again." }
    }
}

# 调用主函数
Main
