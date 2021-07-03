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
Import-Module -DisableNameChecking $PSScriptRoot\library\Tweaks.psm1
Import-Module -DisableNameChecking $PSScriptRoot\library\GeneralFunctions.psm1

$title = "Windows Toolbox $version"
$host.UI.RawUI.WindowTitle = $title
Info

$objects =  @{
    #'Help' = 'Info'
    'Exit' = 'Exit'
    'Restart' = 'Restart'
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
            'Notepad++',
            'Github Desktop',
            'Github CLI',
            'Git',
            'JRE 8',
            'Python',
            'puTTY'
        )"

        'Communication Programs' = "@(
            'Discord',
            'Slack',
            'Zoom',
            'Skype'
        )"

        'Gaming stuff' = "@(
            'Steam',
            'OBS Studio'
        )"

        'Multimedia' = "@(
            'iTunes',
            'Spotify',
            'VLC'
        )"
    }

    'Privacy Settings' = "@(
        'Disable Telemetry',
        'Privacy Fixes (WIP)',
        'Disable App Suggestions',
        'Disable Tailored Experiences',
        'Disable Advertising ID'
    )"

    'Tweaks' = "@(
        'Enable Dark Mode', 
        'Lower RAM usage',
        'Enable photo viewer',
        'Disable Prefetch prelaunch',
        'Disable Edge prelaunch',
        'Use UTC time',
        'Disable ShellExperienceHost',
        'Disable SearchUI'
    )"
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
            "Notepad++" {
                InstallChoco
                choco install notepadplusplus
            }
            "Github Desktop" {
                InstallChoco
                choco install github-desktop
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
            "Python" {
                InstallChoco
                choco install python
            }
            "puTTY" {
                InstallChoco
                choco install putty
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
            "Skype" {
                InstallChoco
                choco install skype
            }

            # Gaming stuff 
            "Steam" {
                InstallChoco
                choco install steam
            }
            "OBS Studio" {
                InstallChoco
                choco install obs-studio
            }     
            
            # Multimedia
            "iTunes" {
                InstallChoco
                choco install itunes
            }
            "Spotify" {
                InstallChoco
                choco install spotify
            }
            "VLC" {
                InstallChoco
                choco install vlc
            }
        
        #Tweaks
            "Enable Dark Mode" {
                DarkMode
            }
            "Lower RAM usage" {
                RAM
            }
            "Enable photo viewer" {
                EnablePhotoViewer
            }
            "Disable Prefetch prelaunch" {
                DisablePrefetchPrelaunch
            }
            "Disable Edge prelaunch" {
                DisableEdgePrelaunch
            }
            "Use UTC time" {
                UseUTC
            }
            "Disable ShellExperienceHost" {
                $yousure = Read-Host "Are you sure? This will somewhat break Explorer, WSL, etc (y/n)"
                if ($yousure -eq "y") {
                    DisableShellExperienceHost
                }
                else {
                    & $PSScriptRoot\main.ps1
                }
            }
            "Disable SearchUI" {
                DisableSearchUI
            }

        # Misc
            #"Help" {
            #    Info
            #}
            "Exit" {
                Exit
            }
            "Restart" {
                Restart
            }
    }
} until($mainMenu -eq "ForeverLoop")