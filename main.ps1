# Self-elevate the script if required
# Get the ID and security principal of the current user account
 $myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
 $myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)

 # Get the security principal for the Administrator role
 $adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator

 # Check to see if we are currently running "as Administrator"
 if ($myWindowsPrincipal.IsInRole($adminRole))
    {
    # We are running "as Administrator"
    }
 else
    {
    # We are not running "as Administrator" - so relaunch as administrator

    # Create a new process object that starts PowerShell
    $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";

    # Specify the current script path and name as a parameter
    $newProcess.Arguments = $myInvocation.MyCommand.Definition;

    # Indicate that the process should be elevated
    $newProcess.Verb = "runas";

    # Start the new process
    [System.Diagnostics.Process]::Start($newProcess) | Out-Null

    # Exit from the current, unelevated, process
    exit
}

Set-Location -Path $PSScriptRoot

Set-ExecutionPolicy Unrestricted -Scope CurrentUser
Get-ChildItem -Recurse *.ps*1 | Unblock-File

Import-Module -DisableNameChecking $PSScriptRoot\library\Write-Menu.psm1
Import-Module -DisableNameChecking $PSScriptRoot\library\WinCore.psm1
Import-Module -DisableNameChecking $PSScriptRoot\library\PrivacyFunctions.psm1
Import-Module -DisableNameChecking $PSScriptRoot\library\Tweaks.psm1
Import-Module -DisableNameChecking $PSScriptRoot\library\GeneralFunctions.psm1
Import-Module -DisableNameChecking $PSScriptRoot\library\DebloatFunctions.psm1
Import-Module -DisableNameChecking $PSScriptRoot\library\UndoFunctions.psm1

$title = "Windows Toolbox $version"
$host.UI.RawUI.WindowTitle = $title

[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

Clear-Host

$build = (Get-CimInstance Win32_OperatingSystem).version
if ($build -eq "10.0.10240") {
    Read-Host "Sorry, your Windows version is not supported, and never will be :( . Press Enter to exit"
    Exit
} elseif ($build -eq "10.0.17134") {
    Write-Warning "Your Windows Version is too old to run Winget. Using Chocolatey"
    InstallChoco
    $global:pkgmgr = "choco"
    Read-Host "Press enter to continue"
    Clear-Host
} else {
    try {
        # Check if winget is already installed
        $er = (invoke-expression "winget -v") 2>&1
        if ($lastexitcode) { throw $er }
        Write-Host "winget is already installed."
        Read-Host "Press enter to continue"
        Clear-Host
    }
    catch {
        # If winget is not installed. Install it from the Github release
        Write-Host "winget is not found, installing it right now."
	
        $download = "https://github.com/microsoft/winget-cli/releases/download/v1.0.11692/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
        Write-Host "Dowloading latest release"
        Invoke-WebRequest -Uri $download -OutFile $PSScriptRoot\winget-latest.appxbundle
	
        Write-Host "Installing the package"
        Add-AppxPackage -Path $PSScriptRoot\winget-latest.appxbundle

        Read-Host "Press enter to continue"
        Clear-Host
    }
    $global:pkgmgr = "winget"
}

setup
Info

$objects = @{

    'Debloat' = "@(
        'Disable Windows Defender (NOT RECOMMENDED)',
        'Remove Default UWP apps',
        'Remove OneDrive',
        'Optimize Windows Updates',
        'Disable services',
        'Disable Cortana',
        'Remove Internet Explorer'
    )"

    'Privacy Settings' = "@(
        'Disable Telemetry',
        'Privacy Fixes (WIP)',
        'Disable App Suggestions',
        'Disable Tailored Experiences',
        'Disable Advertising ID',
        'Disable Activity History'
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

        'UI Tweaks' = @{
            'Shell tweaks' = "@(
                'Enable dark mode',
                'Disable Aero Shake',
                'Switch Windows With a Single Click on the Taskbar',
                'Disable Action Center',
                'Disable Accessibility Keys',
                'Set Win+X menu to Command Prompt',
                'Fix No Internet prompt',
                'Enable verbose startup / shutdown messages'
            )"

            'Explorer tweaks' = "@(
                'Remove user folders under This PC',
                'Show build number on desktop',
                'Show full directory path in Explorer title bar'
            )"
        }   
    }    

    'Install Apps' = @{
        'Browsers' = "@(
            'Firefox',
            'Google Chrome',
            'Edge Chromium',
            'Brave',
            'Vivaldi',
            'Tor Broswer'
        )"

        'Dev Tools' = "@(
            'Visual Studio Code',
            'Atom',
            'Notepad++',
            'Github Desktop',
            'Github CLI',
            'Git',
            'JRE 8',
            'Python 3',
            'Python 2',
            'PowerShell',
            'PuTTY',
            'Node.JS',
            'Vim',
            'Docker',
            'Windows Subsystem for Linux'
        )"

        'Communication Programs' = "@(
            'Discord',
            'Slack',
            'Zoom',
            'Skype',
            'Telegram',
            'Zalo'
        )"

        'Gaming/Streaming' = "@(
            'Steam',
            'OBS Studio',
            'Epic Games Launcher',
            'Twitch'
        )"
        
        'Multimedia' = "@(
            'iTunes',
            'Spotify',
            'VLC',
            'Kodi',
            'Audacity'
        )"

        'Utilities' = @{
            'Password managers' = "@(
                'LastPass', 
                'Dashlane'
            )"

            'Hypervisors / Emulators' = "@(
                'VMware Workstation Pro',
                'VMware Workstation Player',
                'HyperV',
                'VirtualBox',
                'DOSBox'
            )"

            'Other' = "@(
                '7-Zip',
                'WinDynamicDesktop',
                'PowerToys',
                'Internet Download Manager'
            )"
        }
    }

    'Undo Scripts (WIP)' = "@(
        '(Re)Enable Telemetry',
        '(Re)Enable Windows Defender',
        '(Re)Install OneDrive',
        '(Re)Install default UWP apps'
    )"

    # 'Restart PC' = 'Restart'
    # 'Help' = 'Info'
    # 'Exit' = 'Exit'
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
        "Remove Internet Explorer" {
            RemoveIE
        }

        # Privacy menu
        "Disable Telemetry" {
            DisableTelemetry
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

        "Disable Activity History" {
            DisableActivityHistory
        }
        
        # Install Menu

        # Browsers

        "Firefox" {
            if ($global:pkgmgr -eq "choco") {
                choco install firefox            
            } elseif ($global:pkgmgr -eq "winget") {
                winget install Mozilla.Firefox
            }
        }

        "Google Chrome" {
            if ($global:pkgmgr -eq "choco") {
                choco install googlechrome
            } elseif ($global:pkgmgr -eq "winget") {
                winget install Google.Chrome
            }
        }

        "Edge Chromium" {
            if ($global:pkgmgr -eq "choco") {
                choco install microsoft-edge
            } elseif ($global:pkgmgr -eq "winget") {
                winget install Microsoft.Edge
            }
        }

        "Brave" {
            if ($global:pkgmgr -eq "choco") {
                choco install brave
            } elseif ($global:pkgmgr -eq "winget") {
                winget install BraveSoftware.BraveBrowser
            }
        }

        "Vivaldi" {
            if ($global:pkgmgr -eq "choco") {
                choco install vivaldi
            } elseif ($global:pkgmgr -eq "winget") {
                winget install VivaldiTechnologies.Vivaldi
            }
        }

        "Tor Broswer" {
            if ($global:pkgmgr -eq "choco") {
                choco install tor-broswer
            } elseif ($global:pkgmgr -eq "winget") {
                winget install TorProject.TorBroswer
            }
        }

        # Dev Tools

        "Visual Studio Code" {
            if ($global:pkgmgr -eq "choco") {
                choco install vscode
            } elseif ($global:pkgmgr -eq "winget") {
                winget install Microsoft.VisualStudioCode
            }
        }

        "Atom" {
            if ($global:pkgmgr -eq "choco") {
                choco install atom
            } elseif ($global:pkgmgr -eq "winget") {
                winget install GitHub.Atom
            }
        }

        "Notepad++" {
            if ($global:pkgmgr -eq "choco") {
                choco install notepadplusplus
            } elseif ($global:pkgmgr -eq "winget") {
                winget install Notepad++.Notepad++
            }
        }

        "Github Desktop" {
            if ($global:pkgmgr -eq "choco") {
                choco install github-desktop
            } elseif ($global:pkgmgr -eq "winget") {
                winget install GitHub.GitHubDesktop
            }
        }

        "Github CLI" {
            if ($global:pkgmgr -eq "choco") {
                choco install gh
            } elseif ($global:pkgmgr -eq "winget") {
                winget install GitHub.cli
            }
        }

        "Git" {
            if ($global:pkgmgr -eq "choco") {
                choco install git
            } elseif ($global:pkgmgr -eq "winget") {
                winget install Git.Git
            }
        }

        "JRE 8" {
            if ($global:pkgmgr -eq "choco") {
                choco install jre8
            } elseif ($global:pkgmgr -eq "winget") {
                winget install Oracle.JavaRuntimeEnvironment
            }
        }
            
        "Python 3" {
            if ($global:pkgmgr -eq "choco") {
                choco install python3
            } elseif ($global:pkgmgr -eq "winget") {
                winget install Python.Python.3
            }
        }

        "Python 2" {
            if ($global:pkgmgr -eq "choco") {
                choco install python2
            } elseif ($global:pkgmgr -eq "winget") {
                winget install Python.Python.2
            }
        }

        "PowerShell" {
            if ($global:pkgmgr -eq "choco") {
                choco install powershell-core
            } elseif ($global:pkgmgr -eq "winget") {
                winget install Microsoft.PowerShell
            }
        }

        "PuTTY" {
            if ($global:pkgmgr -eq "choco") {
                choco install putty
            } elseif ($global:pkgmgr -eq "winget") {
                winget install PuTTY.PuTTY
            }
        }

        "Node.JS" {
            if ($global:pkgmgr -eq "choco") {
                choco install nodejs
            } elseif ($global:pkgmgr -eq "winget") {
                winget install OpenJS.Nodejs
            }
        }

        "Vim" {
            if ($global:pkgmgr -eq "choco") {
                choco install vim
            } elseif ($global:pkgmgr -eq "winget") {
                winget install vim.vim
            }
        }

        "Docker" {
            if ($global:pkgmgr -eq "choco") {
                Write-Warning "Docker Cannot Be Installed With Choco"
            } elseif ($global:pkgmgr -eq "winget") {
                winget install Docker.DockerDesktop
            }
        }

        "Windows Subsystem for Linux" {
            InstallWSL
        }

        "Hyper-V" {
            InstallHyperV
        }

        # Communication Menu

        "Discord" {
            if ($global:pkgmgr -eq "choco") {
                choco install discord
            } elseif ($global:pkgmgr -eq "winget") {
                winget install Discord.Discord
            }
        }

        "Slack" {
            if ($global:pkgmgr -eq "choco") {
                choco install slack
            } elseif ($global:pkgmgr -eq "winget") {
                winget install SlackTechnologies.Slack
            }
        }

        "Zoom" {
            if ($global:pkgmgr -eq "choco") {
                choco install zoom
            } elseif ($global:pkgmgr -eq "winget") {
                winget install Zoom.Zoom
            }
        }

        "Skype" {
            if ($global:pkgmgr -eq "choco") {
                choco install skype
            } elseif ($global:pkgmgr -eq "winget") {
                winget install Microsoft.Skype
            }
        }

        "Zalo" {
            if ($global:pkgmgr -eq "choco") {
                choco install zalopc
            } elseif ($global:pkgmgr -eq "winget") {
                winget install VNGCorp.Zalo
            }
        }

        "Telegram" {
            if ($global:pkgmgr -eq "choco") {
                choco install telegram
            } elseif ($global:pkgmgr -eq "winget") {
                winget install Telegram.TelegramDesktop
            } 
        }

        # Gaming stuff

        "Steam" {
            if ($global:pkgmgr -eq "choco") {
                choco install steam-client
            } elseif ($global:pkgmgr -eq "winget") {
                winget install Valve.Steam
            }
        }
        
        "OBS Studio" {
            if ($global:pkgmgr -eq "choco") {
                choco install obs-studio
            } elseif ($global:pkgmgr -eq "winget") {
                winget install OBSProject.OBSStudio
            }
        }

        "Epic Games Launcher" {
            if ($global:pkgmgr -eq "choco") {
                choco install epicgameslauncher
            } elseif ($global:pkgmgr -eq "winget") {
                winget install EpicGames.EpicGamesLauncher
            }
        }

        "Twitch" {
            if ($global:pkgmgr -eq "choco") {
                choco install twitch
            } elseif ($global:pkgmgr -eq "winget") {
                winget install Twitch.Twitch
            }
        }

        # Multimedia

        "iTunes" {
            if ($global:pkgmgr -eq "choco") {
                choco install itunes
            } elseif ($global:pkgmgr -eq "winget") {
                winget install Apple.iTunes
            }
        }

        "Spotify" {
            if ($global:pkgmgr -eq "choco") {
                choco install spotify
            } elseif ($global:pkgmgr -eq "winget") {
                winget install Spotify.Spotify
            }
        }

        "VLC" {
            if ($global:pkgmgr -eq "choco") {
                choco install vlc
            } elseif ($global:pkgmgr -eq "winget") {
                winget install VideoLAN.VLC
            }
        }

        "Kodi" {
            if ($global:pkgmgr -eq "choco") {
                choco install kodi
            } elseif (global:pkgmgr -eq "winget") {
                winget install XBMCFoundation.Kodi
            }
        }

        "Audacity" {
            if ($global:pkgmgr -eq "choco") {
                choco install audacity
            } elseif ($global:pkgmgr -eq "winget") {
                winget install Audacity.Audacity
            }
        }

        #Utilities

        "TeamViewer" {
            if ($global:pkgmgr -eq "choco") {
                choco install teamviewer
            } elseif ($global:pkgmgr -eq "winget") {
                winget install TeamViewer.TeamViewer
            }
        }

        #Password managers

        "LastPass" {
            if ($global:pkgmgr -eq "choco") {
                choco install lastpass
            } elseif ($global:pkgmgr -eq "winget") {
                winget install LogMeIn.LastPass
            }
        }

        "Dashlane" {
            if ($global:pkgmgr -eq "choco") {
                choco install dashlane
            } elseif ($global:pkgmgr -eq "winget") {
                winget install Dashlane.Dashlane
            }
        }

        #Virtualization

        'VMware Workstation Pro' {
            if ($global:pkgmgr -eq "choco") {
                choco install vmwareworkstation
            } elseif ($global:pkgmgr -eq "winget") {
                winget install VMware.WorkstationPro
            }
        }

        'VMware Workstation Player' {
            if ($global:pkgmgr -eq "choco") {
                choco install vmware-workstation-player
            } elseif ($global:pkgmgr -eq "winget") {
                winget install VMware.WorkstationPlayer
            }
        }

        'VirtualBox' {
            if ($global:pkgmgr -eq "choco") {
                choco install virtualbox
            } elseif ($global:pkgmgr -eq "winget") {
                winget install Oracle.VirtualBox
            }
        }

        'DOSBox' {
            if ($global:pkgmgr -eq "choco") {
                choco install dosbox
            } elseif ($global:pkgmgr -eq "winget") {
                winget install DOSBox.DOSBox
            }
        }

        #Other

        "7-Zip" {
            if ($global:pkgmgr -eq "choco") {
                choco install 7zip
            } elseif ($global:pkgmgr -eq "winget") {
                winget install 7zip.7zip
            }
        }

        "WinDynamicDesktop" {
            if ($global:pkgmgr -eq "choco") {
                choco install windynamicdesktop
            } elseif ($global:pkgmgr -eq "winget") {
                winget install t1m0thyj.WinDynamicDesktop
            }
        }

        "PowerToys" {
            if ($global:pkgmgr -eq "choco") {
                choco install powertoys
            } elseif ($global:pkgmgr -eq "winget") {
                winget install Microsoft.PowerToys
            }
        }

        "Internet Download Manager" {
            if ($global:pkgmgr -eq "choco") {
                choco install internetdownloadmanager
            } elseif ($global:pkgmgr -eq "winget") {
                winget install Tonec.InternetDownloadManager
            }
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

        #Explorer tweaks
        "Remove user folders under This PC" {
            RemoveThisPClutter
        }

        "Show build number on desktop" {
            ShowBuildNumberOnDesktop
        }

        "Show full directory path in Explorer's title bar" {
            ShowExplorerFullPath
        }

        #Shell tweaks
        "Enable dark mode" {
            DarkMode
        }

        "Disable Aero Share" {
            DisableAeroShake
        }

        "Switch Windows With a Single Click on the Taskbar" {
            TBSingleClick
        }
        "Disable Action Center" {
            DisableActionCenter
        }

        "Disable Accessibility Keys" {
            DisableAccessibilityKeys
        }

        "Fix No Internet prompt" {
            FixNoInternetPrompt
        }

        "Set Win+X menu to Command Prompt" {
            SetWinXMenuCMD
        }

        "Enable verbose startup / shutdown messages" {
            EnableVerboseStartup
        }

        # Undo
        "(Re)Enable Telemetry" {
            EnableTelemetry
        }
        "(Re)Enable Windows Defender" {
            EnableDefender
        }
        "(Re)Install OneDrive" {
            InstallOneDrive
        }
        "(Re)Install default UWP apps" {
            ReinstallDefaultApps
        }

        # Misc
        "Help" {
            Info
        }

        "Exit" {
            Quit 
        }

        "Restart PC" {
            Restart
        }
    }
    Read-Host "Press Enter To Continue"
} until($mainMenu -eq "ForeverLoop")
