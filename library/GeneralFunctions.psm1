# General functions

$version = "1.0.1"
$build = (Get-CimInstance Win32_OperatingSystem).version
$winver = (Get-WmiObject -class Win32_OperatingSystem).Caption
$chocoinstalled = Get-Command -Name choco.exe -ErrorAction SilentlyContinue

function setup {
    if ($winver -like "*Windows 11*") {
        $winver = '11'
    }
    elseif ($winver -like "*Windows 10*") {
        $winver = '10'
    }
}
function Quit {
    stop-process -id $PID
}

function Restart {
    Restart-Computer
}

function Info {
    Write-Output "Windows Toolbox $version"
    Write-Output "Windows build $build"
    if ($version -lt "$version") {
        Write-Output "Older version of WindowsToolbox is detected, please update WindowsToolbox"
    }
    Write-Output ""
    Write-Output ""
    Write-Output "Please read before using WindowsToolbox"
    Write-Output "- None of the functions have configs (for now), you have to edit them to your liking beforehand."
    Write-Output "- Windows 10 and 11 are the only supported Windows versions (for now)."
    Write-Output "- There is no undo (for now), all scripts are provided AS IS. You use them at your own risk."
    if ($build -ne "10.0.17134") {
        Write-Output "- To Use $global:notpkgmgr instead of $global:pkgmgr edit $env:APPDATA\WindowsToolbox\config.json."
    }
    Write-Output "- Navigation: Use the arrow keys to navigate, Enter to select and ESC to go back"
    Write-Output ""
    Write-Output "Things that break core functions (Very unlikely to be fixed)"
    Write-Output "- Disable ShellExperienceHost"
    Write-Output "- Disable SearchUI"
    Write-Output ""
    Write-Output "Things that break Windows 11 (will be fixed):"
    Write-Output "- Disabling telemetry (Disables updates. See #7)"
    Write-Output ""
    Write-Output ""
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
    else {
        Install-WindowsFeature -Name "Hyper-V" -IncludeManagementTools -WarningAction SilentlyContinue | Out-Null
    }
}
