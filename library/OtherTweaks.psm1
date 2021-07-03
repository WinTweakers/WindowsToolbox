##Other tweaks
Import-Module $PSScriptRoot\WinCore.psm1
Import-Module -DisableNameChecking $PSScriptRoot\Take-Own.psm1
function DarkMode {
    New-FolderForced -Path "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
        Set-ItemProperty -Path "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" "AppsUseLightTheme" "0"
    New-FolderForced -Path "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
        Set-ItemProperty -Path "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" "AppsUseLightTheme" "0"
}

function RAM {
    Write-Output "WIP"
}