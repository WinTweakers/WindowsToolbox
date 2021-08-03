# General functions

$version = "1.0.2"
$title = "Windows Toolbox $version"
$host.UI.RawUI.WindowTitle = $title
$build = (Get-CimInstance Win32_OperatingSystem).version
$winver = (Get-WmiObject -class Win32_OperatingSystem).Caption
$chocoinstalled = Get-Command -Name choco.exe -ErrorAction SilentlyContinue

function setup {
    if ($winver -like "*Windows 11*") { $winver = '11' }
    elseif ($winver -like "*Windows 10*") { $winver = '10' }
}
function Quit {
    stop-process -id $PID
}

function Restart { Restart-Computer }

function Info {
    Write-Output "Windows Toolbox $version"
    Write-Output "Windows build $build `n`n"
    if ($version -lt "$version") { Write-Output "Older version of WindowsToolbox is detected, please update WindowsToolbox" }
    Write-Output "Please read before using WindowsToolbox"
    Write-Output "- None of the functions have configs (for now), you have to edit them to your liking beforehand."
    Write-Output "- Windows 10 and 11 are the only supported Windows versions (for now)."
    Write-Output "- There is no undo (for now), all scripts are provided AS IS. You use them at your own risk."
    if ($build -ne "10.0.17134") { Write-Output "- To Use $global:notpkgmgr instead of $global:pkgmgr edit $env:APPDATA\WindowsToolbox\config.json." }
    Write-Output "- Navigation: Use the arrow keys to navigate, Enter to select and ESC to go back `n"
    Write-Output "Things that break core functions (Very unlikely to be fixed)"
    Write-Output "- Disable ShellExperienceHost"
    Write-Output "- Disable SearchUI `n"
    Write-Output "Things that break (or doesn't work on) Windows 11 (will be fixed):"
    Write-Output "- Disabling telemetry (Disables updates. See #7)"
    Write-Output "- Remove user folders under This PC  `n`n"
    Read-Host "Press Enter to continue"
}

function InstallChoco {
    if ($chocoinstalled -eq $null) {
        Write-Output "Seems like Chocolatey is not installed, installing now"
        Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
        refreshenv
        choco feature enable -n allowGlobalConfirmation
    } else {
        choco feature enable -n allowGlobalConfirmation
        Write-Output "Chocolatey is already installed"
    }
}

function InstallWSL {
    Write-Output "Installing WSL..."
    Get-WindowsOptionalFeature -Online | Where-Object { $_.FeatureName -eq "Microsoft-Windows-Subsystem-Linux" } | Enable-WindowsOptionalFeature -Online -NoRestart -WarningAction SilentlyContinue | Out-Null
}

function InstallHyperV {
    Write-Output "Installing Hyper-V..."
    if ((Get-CimInstance -Class "Win32_OperatingSystem").ProductType -eq 1) {
        Get-WindowsOptionalFeature -Online | Where-Object { $_.FeatureName -eq "Microsoft-Hyper-V-All" } | Enable-WindowsOptionalFeature -Online -NoRestart -WarningAction SilentlyContinue | Out-Null
    }
    else { Install-WindowsFeature -Name "Hyper-V" -IncludeManagementTools -WarningAction SilentlyContinue }
}

function MSDOSMode {
    Write-Output '"MS-DOS Mode" for Windows 10 (PoC, made by Endermanch)'
    Write-Output "This is provided WITHOUT WARRANTY OF ANY KIND and is only a Proof of Concept."
    Write-Output "Big thanks to Endermanch for this and his discovery of the BCPE exploit. `n`n"
    
    $conflocation = "$env:APPDATA\WindowsToolbox\"
    $windowsdos = "https://dl.malwarewatch.org/multipurpose/Windows10DOS.zip"
    
    Write-Output "Downloading"
    Invoke-WebRequest -Uri $windowsdos -OutFile $conflocation\Windows10DOS.zip
    
    Write-Output "Installing 7Zip4PowerShell (sorry, Expand-Archive does not support passwords)"
    Install-Module 7Zip4PowerShell -Scope CurrentUser -Force -Verbose
    Clear-Host
    Write-Output "Extracting..."
    Expand-7Zip -ArchiveFileName $conflocation\Windows10DOS.zip -TargetPath $conflocation -Password "mysubsarethebest" -Verbose
    
    Write-Output "Copying to System32"
    Copy-Item $conflocation\msdos.bat -Destination "C:\Windows\System32" -Force
    Copy-Item $conflocation\win.bat -Destination "C:\Windows\System32" -Force
    Copy-Item $conflocation\reboot.bat -Destination "C:\Windows\System32" -Force

    Write-Output "Removing leftovers"
    Remove-Item -Path $conflocation\msdos.bat -Force
    Remove-Item -Path $conflocation\win.bat -Force
    Remove-Item -Path $conflocation\reboot.bat -Force
    
    Write-Output "Please use WinXEditor to add the entry to the Win+X menu"
    Start-Process $conflocation\WinXEditor\WinXEditor.exe
    Read-Host "Done"
}
