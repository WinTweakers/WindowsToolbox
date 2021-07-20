# General functions

$version = "1.0.0-Release Canidate 3"
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
    Write-Output "- None of the scripts have configs (for now), you have to edit them to your liking beforehand."
    Write-Output "- Windows 10 and 11 are the only supported Windows versions (until Windows 12?)"
    Write-Output "- There is no undo (for now), all scripts are provided AS-IS and you use them at your own risk"
    Write-Output "- Navigation: Use the arrow keys to navigate, Enter to select and Esc to go back"
    Write-Output ""
    Write-Output "Stuff that breaks core functions (very unlikely to be fixed cuz this is Windows we're talking about)"
    Write-Output "- Disable ShellExperienceHost"
    Write-Output "- Disable SearchUI"
    Write-Output ""
    Write-Output "Stuff that breaks Windows 11 (will be fixed ofc):"
    Write-Output "- Disabling telemetry (if using insider)"
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
        Write-Output "Chocolatey Version $testchoco is already installed"
    }
}

function InstallWSL {
    Write-Output "Installing Linux Subsystem..."
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
