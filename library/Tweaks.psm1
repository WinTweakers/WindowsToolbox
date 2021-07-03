# tweaks
Import-Module $PSScriptRoot\WinCore.psm1
Import-Module -DisableNameChecking $PSScriptRoot\Take-Own.psm1
function DarkMode {
    if((Test-Path -LiteralPath "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize") -ne $true) {  New-Item "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -force -ea SilentlyContinue };
    if((Test-Path -LiteralPath "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize") -ne $true) {  New-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -force -ea SilentlyContinue };
    New-ItemProperty -LiteralPath 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize' -Name 'AppsUseLightTheme' -Value 0 -PropertyType DWord -Force -ea SilentlyContinue;
    New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize' -Name 'AppsUseLightTheme' -Value 0 -PropertyType DWord -Force -ea SilentlyContinue;
}

function RAM {
    if((Test-Path -LiteralPath "HKLM:\SYSTEM\CurrentControlSet\Control") -ne $true) {  New-Item "HKLM:\SYSTEM\CurrentControlSet\Control" -force -ea SilentlyContinue };
    if((Test-Path -LiteralPath "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile") -ne $true) {  New-Item "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -force -ea SilentlyContinue };
    if((Test-Path -LiteralPath "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks") -ne $true) {  New-Item "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks" -force -ea SilentlyContinue };
    if((Test-Path -LiteralPath "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Audio") -ne $true) {  New-Item "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Audio" -force -ea SilentlyContinue };
    if((Test-Path -LiteralPath "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Capture") -ne $true) {  New-Item "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Capture" -force -ea SilentlyContinue };
}

function DisablePrefetchPrelaunch {
    Disable-MMAgent -ApplicationPreLaunch
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v EnablePrefetcher /t REG_DWORD /d "0" /f
    reg add "HKLM\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main" /v AllowPrelaunch /t REG_DWORD /d "0" /f
    
}

function DisableEdgePrelaunch {
    if((Test-Path -LiteralPath "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main") -ne $true) {  New-Item "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main" -force -ea SilentlyContinue };
    if((Test-Path -LiteralPath "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\TabPreloader") -ne $true) {  New-Item "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\TabPreloader" -force -ea SilentlyContinue };
    New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main' -Name 'AllowPrelaunch' -Value 0 -PropertyType DWord -Force -ea SilentlyContinue;
    New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\TabPreloader' -Name 'AllowTabPreloading' -Value 0 -PropertyType DWord -Force -ea SilentlyContinue;
}

function EnablePhotoViewer {
    Write-Output "Enabling Photo Viewer"
    if((Test-Path -LiteralPath "HKCU:\Software\Classes\.jpg") -ne $true) {  New-Item "HKCU:\Software\Classes\.jpg" -force -ea SilentlyContinue };
    if((Test-Path -LiteralPath "HKCU:\Software\Classes\.jpeg") -ne $true) {  New-Item "HKCU:\Software\Classes\.jpeg" -force -ea SilentlyContinue };
    if((Test-Path -LiteralPath "HKCU:\Software\Classes\.gif") -ne $true) {  New-Item "HKCU:\Software\Classes\.gif" -force -ea SilentlyContinue };
    if((Test-Path -LiteralPath "HKCU:\Software\Classes\.png") -ne $true) {  New-Item "HKCU:\Software\Classes\.png" -force -ea SilentlyContinue };
    if((Test-Path -LiteralPath "HKCU:\Software\Classes\.bmp") -ne $true) {  New-Item "HKCU:\Software\Classes\.bmp" -force -ea SilentlyContinue };
    if((Test-Path -LiteralPath "HKCU:\Software\Classes\.tiff") -ne $true) {  New-Item "HKCU:\Software\Classes\.tiff" -force -ea SilentlyContinue };
    if((Test-Path -LiteralPath "HKCU:\Software\Classes\.ico") -ne $true) {  New-Item "HKCU:\Software\Classes\.ico" -force -ea SilentlyContinue };
    New-ItemProperty -LiteralPath 'HKCU:\Software\Classes\.jpg' -Name '(default)' -Value 'PhotoViewer.FileAssoc.Tiff' -PropertyType String -Force -ea SilentlyContinue;
    New-ItemProperty -LiteralPath 'HKCU:\Software\Classes\.jpeg' -Name '(default)' -Value 'PhotoViewer.FileAssoc.Tiff' -PropertyType String -Force -ea SilentlyContinue;
    New-ItemProperty -LiteralPath 'HKCU:\Software\Classes\.gif' -Name '(default)' -Value 'PhotoViewer.FileAssoc.Tiff' -PropertyType String -Force -ea SilentlyContinue;
    New-ItemProperty -LiteralPath 'HKCU:\Software\Classes\.png' -Name '(default)' -Value 'PhotoViewer.FileAssoc.Tiff' -PropertyType String -Force -ea SilentlyContinue;
    New-ItemProperty -LiteralPath 'HKCU:\Software\Classes\.bmp' -Name '(default)' -Value 'PhotoViewer.FileAssoc.Tiff' -PropertyType String -Force -ea SilentlyContinue;
    New-ItemProperty -LiteralPath 'HKCU:\Software\Classes\.tiff' -Name '(default)' -Value 'PhotoViewer.FileAssoc.Tiff' -PropertyType String -Force -ea SilentlyContinue;
    New-ItemProperty -LiteralPath 'HKCU:\Software\Classes\.ico' -Name '(default)' -Value 'PhotoViewer.FileAssoc.Tiff' -PropertyType String -Force -ea SilentlyContinue;
    Write-Output "Done"
}

function UseUTC {
    if((Test-Path -LiteralPath "HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation") -ne $true) {  New-Item "HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation" -force -ea SilentlyContinue };
    New-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation' -Name 'RealTimeIsUniversal' -Value 1 -PropertyType DWord -Force -ea SilentlyContinue;
    Write-Output "Done"
}

function DisableShellExperienceHost {
    #This will somewhat break internet connectivity, Explorer, WSL, etc
    Write-Output "Disabling ShellExperienceHost"
    taskkill.exe /F /IM ShellExperienceHost.exe
    Move-Item -Path "%windir%\SystemApps\ShellExperienceHost_cw5n1h2txyewy" -Destination "%windir%\SystemApps\ShellExperienceHost_cw5n1h2txyewy.bak" 
    Write-Output "Done"
}

function DisableSearchUI {
    Write-Output "Disabling SearchUI"
    taskkill.exe /F /IM SearchUI.exe
    Move-Item -Path "%windir%\SystemApps\Microsoft.Windows.Cortana_cw5n1h2txyewy" -Destination "%windir%\SystemApps\Microsoft.Windows.Cortana_cw5n1h2txyewy.bak"
    Write-Output "Done"
}

function ImproveSSD {
    # SSD life improvement
    fsutil behavior set DisableLastAccess 1
    fsutil behavior set EncryptPagingFile 0
}

function GodMode {
    $DesktopPath = [Environment]::GetFolderPath("Desktop");
    mkdir "$DesktopPath\GodMode.{ED7BA470-8E54-465E-825C-99712043E01C}"
}