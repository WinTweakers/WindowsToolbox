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
Import-Module -DisableNameChecking $PSScriptRoot\library\DebloatFunctions.psm1

$title = "Windows Toolbox $version"
$host.UI.RawUI.WindowTitle = $title
$build = (Get-CimInstance Win32_OperatingSystem).version
if ($build -lt "10.0.10240") {
    Read-Host "Sorry, your Windows version is not supported, and will never be :( . Press Enter to exit"
    Exit
}
else {
    setup
    Info
}


$objects = @{

    'Debloat' = "@(
        'Disable Windows Defender (NOT RECOMMENDED)',
        'Remove Default UWP apps',
        'Remove OneDrive',
        'Optimize Windows Updates',
        'Disable services',
        'Disable Cortana'
    )"

    'Privacy Settings' = "@(
        'Disable Telemetry',
        'Privacy Fixes (WIP)',
        'Disable App Suggestions',
        'Disable Tailored Experiences',
        'Disable Advertising ID'
    )"

    'Tweaks' = @{
        'System Tweaks' = "@(
            'Lower RAM usage',
            'Enable photo viewer',
            'Disable Prefetch prelaunch',
            'Disable Edge prelaunch',
            'Use UTC time',
            'Disable ShellExperienceHost',
            'Disable SearchUI',
            'Enable GodMode',
            'Improve SSD Lifespan (HIGHLY RECOMMENDED IF YOU HAVE AN SSD)'
        )"

        'UI Tweaks' = "@(
            'Remove user folders under This PC',
            'Enable dark mode',
            'Disable Aero Shake',
            'Switch Windows With a Single Click on the Taskbar'
        )"
    }    

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
            'PuTTY',
            'Windows Subsystem for Linux',
            'Hyper-V'
        )"

        'Communication Programs' = "@(
            'Discord',
            'Slack',
            'Zoom',
            'Skype'
        )"

        'Gaming/Streaming' = "@(
            'Steam',
            'OBS Studio'
        )"
        
        'Multimedia' = "@(
            'iTunes',
            'Spotify',
            'VLC'
        )"
    }

    #'Restart' = 'Restart'
    #'Help' = 'Info'
    #'Exit' = 'Exit'
}

do {
    $mainMenu = Write-Menu -Title $title -Entries $objects
    switch ($mainMenu) {
        #Debloat menu
            "Disable Windows Defender (NOT RECOMMENDED)" {
                DisableWindowsDefender   
            }
            "Remove Default UWP apps" {
                RemoveDefaultApps
            }
            "Remove OneDrive" {
                RemoveOneDrive
            }
            "Optimize Windows Updates" {
                OptimizeUpdates
            }
            "Disable services" {
                DisableServices
            }
            "Disable Cortana" {
                DisableCortana
            }

        # Privacy menu

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

        "PuTTY" {
            InstallChoco
            choco install putty
        }
        "Windows Subsystem for Linux" {
            InstallWSL
        }
        "Hyper-V" {
            InstallHyperV
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
            #System tweaks
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
                DisableShellExperienceHost 
            }
            "Enable GodMode" {
                GodMode
            }
            "Improve SSD Lifespan (HIGHLY RECOMMENDED IF YOU HAVE AN SSD)" {
                ImproveSSD
            }

            "Disable SearchUI" {
                DisableSearchUI
            }

            #UI Tweaks
            "Remove user folders under This PC" {
                RemoveThisPClutter
            }
            "Enable dark mode" {
                DarkMode
            }
            "Disable Aero Share" {
                DisableAeroShake
            }

        "Switch Windows With a Single Click on the Taskbar" {
            TBSingleClick
        }

        # Misc
        "Help" {
            Info
        }
        "Exit" {
            Exit
        }
        "Reboot" {
            Restart
        }
    }
} until($mainMenu -eq "ForeverLoop")