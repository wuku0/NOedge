function Delete-Item {
    param(
        [string]$itemPath,
        [string]$itemName
    )

    try {
        if (Test-Path $itemPath) {
            if (Test-PathType -Path $itemPath -PathType Container) {
                Remove-Item -Path $itemPath -Recurse -Force
                Write-Host ("Folder [red]${itemName}[/red] deleted.")
            }
            else {
                icacls "$itemPath" /setowner Administrators /T /C
                Stop-Process -Name $itemName -Force -ErrorAction SilentlyContinue
                Remove-Item -Path $itemPath
                Write-Host ("File [red]${itemName}[/red] deleted.")
            }
        }
        else {
            Write-Host ("Folder/File [yellow]${itemName}[/yellow] not found.")
        }
    }
    catch [System.UnauthorizedAccessException] {
        Write-Host ("Access denied for [yellow]${itemName}[/yellow].")
    }
    catch {
        Write-Host ("An error occurred: $($_.Exception.Message)")
    }
}

function Make-Folder-Readonly {
    param(
        [string]$folderPath,
        [string]$folderName
    )

    try {
        if (Test-Path $folderPath) {
            Set-ItemProperty -Path $folderPath -Name IsReadOnly -Value $true
            Write-Host ("Folder [green]${folderName}[/green] is now read-only.")
        }
        else {
            Write-Host ("Folder [yellow]${folderName}[/yellow] not found.")
        }
    }
    catch [System.UnauthorizedAccessException] {
        Write-Host ("Access denied for [yellow]${folderName}[/yellow].")
    }
    catch {
        Write-Host ("An error occurred: $($_.Exception.Message)")
    }
}

function Run-As-Admin {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    
    if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Start-Process -FilePath $PSCommandPath -ArgumentList $args -Verb RunAs
        exit
    }
}

Run-As-Admin

while ($true) {
    Write-Host "NOEdge Script"
    Write-Host "1. Delete MS Edge (Chromium) Folders"
    Write-Host "2. Block EdgeWebView from Updating"
    Write-Host "3. Quit"

    $choice = Read-Host "Enter your choice"

    switch ($choice) {
        '1' {
            Delete-Item "C:\Program Files (x86)\Microsoft\Edge" "MS Edge (Chromium)"
            Delete-Item "C:\Program Files (x86)\Microsoft\EdgeCore" "MS Edge (Chromium)"
            Delete-Item "C:\Program Files (x86)\Microsoft\Temp" "MS Edge (Chromium)"
        }
        '2' {
            Make-Folder-Readonly "C:\Program Files (x86)\Microsoft\EdgeWebView" "EdgeWebView"
        }
        '3' {
            Write-Host "Goodbye!"
            exit
        }
        default {
            Write-Host "Invalid choice. Please try again."
        }
    }
}
