# Self-elevate the script if required
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
    if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
        $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
        Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
        Exit
    }
}

Import-Module $PSScriptRoot\library\Write-Menu.psm1
Import-Module $PSScriptRoot\library\WinCore.psm1
Import-Module $PSScriptRoot\library\PrivacyFunctions.psm1
Import-Module -DisableNameChecking $PSScriptRoot\library\Take-Own.psm1

$title = "Windows Toolbox 1.0.0"
$host.UI.RawUI.WindowTitle = $title

do {
    $mainMenu = Write-Menu -Title $title -Sort -Entries @{
        'Privacy Settings' = "@('Disable Telemetry', 'Privacy Fixes (WIP)')"
    }
    switch ($mainMenu) {
        "Disable Telemetry" {
            Disable-Telemetry
        }
        "Privacy Fixes (WIP)" {
            PrivacyFixSettings
        }
    }
} until($mainMenu -eq "Quit")