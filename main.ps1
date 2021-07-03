# Self-elevate the script if required
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
    if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
        $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
        Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
        Exit
    }
}

Import-Module $PSScriptRoot\library\Write-Menu.psm1
Import-Module -DisableNameChecking $PSScriptRoot\library\WinCore.psm1
Import-Module $PSScriptRoot\library\PrivacyFunctions.psm1
Import-Module -DisableNameChecking $PSScriptRoot\library\Take-Own.psm1

$title = "Windows Toolbox 1.0.0"
$host.UI.RawUI.WindowTitle = $title

$objects =  @{
    'Privacy Settings' = "@(
        'Disable Telemetry',
        'Privacy Fixes (WIP)',
        'Disable App Suggestions',
        'Disable Tailored Experiences',
        'Disable Advertising ID'
    )"
    
    'Install Apps' = @{
        'Browsers' = "@(
            'Firefox',
            'Google Chrome',
            'Brave',
            'Vivaldi'
        )"
        
        'Dev Tools' = "@(
            'Visual Studio Code',
            'Atom',
            'Github CLI',
            'Git',
            'JRE 8'
        )"

        'Communication Programs' = "@(
            'Discord',
            'Slack',
            'Zoom'
        )"
    }
}

do {
    $mainMenu = Write-Menu -Title $title -Entries $objects
    switch ($mainMenu) {
        # Privacy Menu

            "Disable Telemetry" {
                Disable-Telemetry
            }

            "Privacy Fixes (WIP)" {
                PrivacyFixSettings
            }

            "Disable App Suggestions" {
                DisableAppSuggestions
            }

            "Disable Tailored Experiences" {
                DisableTailoredExperiences
            }

            "Disable Advertising ID" {
                DisableAdvertisingID
            }

        # Install Menu

            # Browsers

            "Firefox" {
                InstallChoco
                choco install firefox
            }

            "Google Chrome" {
                InstallChoco
                choco install googlechrome
            }

            "Brave" {
                InstallChoco
                choco install brave
            }

            "Vivaldi" {
                InstallChoco
                choco install vivaldi
            }

            # Dev Tools

            "Visual Studio Code" {
                InstallChoco
                choco install vscode
            }

            "Atom" {
                InstallChoco
                choco install atom
            }

            "Github CLI" {
                InstallChoco
                choco install gh
            }

            "Git" {
                InstallChoco
                choco install git
            }

            "JRE 8" {
                InstallChoco
                choco install jre8
            }

            # Communication Menu

            "Discord" {
                InstallChoco
                choco install discord
            }

            "Slack" {
                InstallChoco
                choco install slack
            }
            
            "Zoom" {
                InstallChoco
                choco install zoom
            }
    }
} until($mainMenu -eq "ForeverLoop")