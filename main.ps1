# Self-elevate the script if required
 $myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
 $myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
 $adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator
 if (-not $myWindowsPrincipal.IsInRole($adminRole))
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

Set-Location $PSScriptRoot

Import-Module .\library\Write-Menu.psm1 -DisableNameChecking
Import-Module .\library\WinCore.psm1 -DisableNameChecking
Clear-Host
Import-Module .\library\PrivacyFunctions.psm1 -DisableNameChecking
Import-Module .\library\Tweaks.psm1 -DisableNameChecking
Import-Module .\library\GeneralFunctions.psm1 -DisableNameChecking
Import-Module .\library\DebloatFunctions.psm1 -DisableNameChecking
Import-Module .\library\UndoFunctions.psm1 -DisableNameChecking

[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

Write-Host "It is recommended that you create a system restore point."
$reply = Read-Host -Prompt "Make One Now? [y/n]"
if ( $reply -match "[yY]" ) {
    Clear-Host
    Enable-ComputerRestore -Drive "$env:SystemDrive"
    Checkpoint-Computer -Description "BeforeWindowsToolbox" -RestorePointType "MODIFY_SETTINGS"
    Read-Host "Press enter to continue"
} else {
    Enable-ComputerRestore -Drive "$env:SystemDrive"
}

Clear-Host

if ($build -lt 10.0.10240) {
    Read-Host "Sorry, your Windows version is not supported, and never will be :( . Press Enter to exit"
    Exit
} elseif ($build -le 10.0.17134) {
    Write-Warning "Your Windows version is too old to run Winget. Using Chocolatey"
    $global:pkgmgr = "choco"
    Clear-Host
} else {
    $global:pkgmgr = "winget"
}

$conflocation = "$env:APPDATA\WindowsToolbox\"
if (!(Test-Path -Path $conflocation)) {
    $JSONData = @{
        pkgmgr = "$global:pkgmgr"
    }
    if ( -not $build -eq "10.0.17134" ) {
        Write-Host "It has been detected that this is your first time using Windows Toolbox, please choose a package manager."
        $reply = Read-Host -Prompt "[W]inget Or [C]hocolatey (winget is recomended)"
        if ( $reply -match "[wW]" ) { $global:pkgmgr = "winget" } elseif ( $reply -match "[cC]" ) { $global:pkgmgr = "choco" }
        Clear-Host
    }
    New-Item -ItemType directory -Path $conflocation | Out-Null
    New-Item -Path $conflocation -Name "config.json" -ItemType "file" | Out-Null
    $JSONData | ConvertTo-Json | Add-Content  -Path "$conflocation\config.json" | Out-Null

} else {
    $JSONData = Get-Content -Path "$conflocation\config.json" -Raw | ConvertFrom-Json
    $global:pkgmgr = $JSONData.pkgmgr
}

if ($global:pkgmgr -eq "choco") { $global:notpkgmgr = "winget" } else { $global:notpkgmgr = "choco" }

if ($global:pkgmgr -eq "choco") {
    InstallChoco
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
        Write-Host "winget is not installed, installing it right now."
	
        $download = "https://github.com/microsoft/winget-cli/releases/download/v1.0.11692/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
        Write-Host "Dowloading the latest release..."
        Invoke-WebRequest -Uri $download -OutFile $PSScriptRoot\winget-latest.appxbundle
	
        Write-Host "Installing the package..."
        Add-AppxPackage -Path $PSScriptRoot\winget-latest.appxbundle

        Read-Host "Press enter to continue"
        Clear-Host
    }
}

setup
Clear-Host
Info

$objects = @{

    '1) Debloat' = "@(
        'Disable Windows Defender (NOT RECOMMENDED)',
        'Disable Windows Defender Cloud',
        'Remove Default UWP apps',
        'Remove OneDrive',
        'Optimize Windows Updates',
        'Disable services',
        'Disable Cortana',
        'Remove Internet Explorer',
        'Remove Xbox bloat'
    )"

    '2) Privacy Settings' = "@(
        'Disable Telemetry',
        'Privacy Fixes (WIP)',
        'Disable App Suggestions',
        'Disable Tailored Experiences',
        'Disable Advertising ID',
        'Disable Activity History',
        'Disable Location Services'
    )"

    '3) Tweaks' = @{
        'System Tweaks' = "@(
            'Lower RAM usage',
            'Enable photo viewer',
            'Disable Prefetch prelaunch',
            'Disable Edge prelaunch',
            'Disable Superfetch',
            'Use UTC time',
            'Disable ShellExperienceHost',
            'Disable SearchUI',
            'Enable GodMode',
            'Improve SSD Lifespan (HIGHLY RECOMMENDED IF YOU HAVE AN SSD)'
        )"

        'UI Tweaks' = @{
            'Appearance' = "@(
                'Enable dark mode',
                'Enable Windows 7-style volume flyout',
                'Enable Windows 7-style battery flyout',
                'Hide People icon on the Taskbar',
                'Restore classic context menu (Windows 11 only)'
            )"

            'Explorer' = "@(
                'Remove user folders under This PC',
                'Show build number on desktop',
                'Show full directory path in Explorer title bar',
                'Change default explorer view to This PC'
            )"

            'Behavior' = "@(
                'Disable Aero Shake',
                'Switch Windows With a Single Click on the Taskbar',
                'Disable Action Center',
                'Disable Accessibility Keys',
                'Set Win+X menu to Command Prompt',
                'Fix No Internet prompt',
                'Enable verbose startup / shutdown messages',
                'Disable Xbox Game DVR and Game Bar'
            )"
        }

        'Boot Configuration Data (BCD)' = "@(
            'Remove entry',
            'Set timeout',
            'Set default',
            'Export BCD configuration',
            'Import BCD configuration'    
        )"
    }    

    '4) Install Apps' = @{
        'Browsers' = "@(
            'Firefox',
            'Google Chrome',
            'Edge Chromium',
            'Brave',
            'Vivaldi',
            'Tor Broswer'
        )"

        'Dev Tools' = @{
            'Text editors | IDEs' = "@(
                'Visual Studio Code',
                'Atom',
                'Notepad++',
                'Sublime Text',
                'Vim'   
            )"
            'Development' = "@(
                'Github Desktop',
                'Github CLI',
                'Git',
                'Heroku CLI',
                'JRE 8',
                'Python 3',
                'Python 2',
                'PowerShell',
                'PuTTY',
                'Node.JS',
                'Docker',
                'Windows Subsystem for Linux'   
            )"
        }

        'Communication' = "@(
            'Discord',
            'Slack',
            'Zoom',
            'Skype',
            'Telegram',
            'Zalo',
            'Microsoft Teams',
            'Teamspeak'
        )"

        'Game Launchers' = "@(
            'Steam',
            'Epic Games Launcher',
            'GOG Galaxy'
        )"

        'Streaming' = "@(
            'OBS Studio',
            'Streamlabs'
        )"
        
        'Multimedia' = @{
            'Imaging' = "@(
                'ShareX',
                'Krita',
                'GIMP',
                'Inkscape' 
            )"

            'Media Playing' = "@(
                'iTunes',
                'Spotify',
                'VLC',
                'Audacity',
                'Kodi',
                'Twitch'   
            )"
        }

        'Utilities' = @{
            'Password managers' = "@(
                'LastPass', 
                'Dashlane',
                'Bitwarden',
                '1Password'
            )"

            'Hypervisors / Emulators' = "@(
                'VMware Workstation Pro',
                'VMware Workstation Player',
                'HyperV (Windows 10/11 Pro Only)',
                'VirtualBox',
                'DOSBox',
                'QEMU'
            )"

            'Hardware info & Benchmarks' = "@(
                'CPU-Z',
                'GPU-Z',
                'CrystalDiskMark',
                'AIDA64 Extreme'
            )"

            'Customisation' = "@( 
                'WinDynamicDesktop',
                'PowerToys',
                'TaskbarX',
                'StartIsBack',
                'Winaero Tweaker (Chocolatey only)'
            )"

            'Archiving' = "@(
                '7-Zip',
                'WinRAR',
                'WinZip (Winget only)'
            )"

            'Remote' = "@(
                'TeamViewer',
                'Parsec'   
            )"

            'Other' = "@(
                'Evernote',
                'Gpg4win',
                'iMazing',
                'Internet Download Manager',
                'MS-DOS Mode for Windows 10 (Proof of Concept, made by Endermanch)',
                'Nitroless (1.0.0-a4)',
                'Authy Desktop'
            )"
        }
    }

    '5) Undo (WIP)' = "@(
        '(Re)Enable Telemetry',
        '(Re)Enable Windows Defender',
        '(Re)Install OneDrive',
        '(Re)Install default UWP apps',
        '(Re)Enable Location Services',
        '(Re)Enable Activity History',
        '(Re)Enable Superfetch',
        'Hide build number on desktop',
        'Disable old context menu (Windows 11 only)',
        'Disable Windows 7-style volume flyout',
        'Disable Windows 7-style battery flyout'
    )"

    '6) Options' = "@(
        '1) Create restore point',
        '2) Change package manager',
        '3) Info',
        '4) Restart Explorer',
        '5) Restart',
        '6) Exit'   
    )"
}

while ($true) {
    $mainMenu = Write-Menu -Sort -Title $title -Entries $objects
    switch ($mainMenu) {
        #Debloat menu
        "Disable Windows Defender (NOT RECOMMENDED)" {
            DisableWindowsDefender   
        }

        "Disable Windows Defender Cloud" {
            DisableWindowsDefenderCloud
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

        "Remove Xbox bloat" {
            RemoveXboxBloat
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

        "Disable Location Services" {
            DisableLocation
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

        "Sublime Text" {
            if ($global:pkgmgr -eq "choco") {
                choco install sublimetext3.app
            } elseif ($global:pkgmgr -eq "winget") {
                winget install SublimeHQ.SublimeText
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

        "Heroku CLI" {
            if($global:pkgmgr -eq "choco") {
                choco install heroku-cli
            } elseif($global:pkgmgr -eq "winget") {
                winget install Heroku.HerokuCLI
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
                Write-Warning "Docker cannot be installed with Chocolatey"
            } elseif ($global:pkgmgr -eq "winget") {
                winget install Docker.DockerDesktop
            }
        }

        "Windows Subsystem for Linux" {
            InstallWSL
        }

        "Hyper-V (Windows 10/11 Pro Only)" {
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

        "Microsoft Teams" {
            if ($global:pkgmgr -eq "choco") {
                choco install microsoft-teams
            } elseif ($global:pkgmgr -eq "winget") {
                winget install Microsoft.Teams
            }
        }

        "Teamspeak" {
            if ($global:pkgmgr -eq "choco") {
                choco install teamspeak
            } elseif ($global:pkgmgr -eq "winget") {
                winget install TeamSpeakSystems.TeamSpeakClient
            }
        }

        # Gaming Menu

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

        "Streamlabs" {
            if ($global:pkgmgr -eq "choco") {
                choco install streamlabs-obs
            } elseif ($global:pkgmgr -eq "winget") {
                winget install Streamlabs.StreamlabsOBS
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

        "GOG Galaxy" {
            if ($global:pkgmgr -eq "choco") {
                choco install goggalaxy
            } elseif ($global:pkgmgr -eq "winget") {
                winget install GOG.Galaxy
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

        "ShareX" {
            if ($global:pkgmgr -eq "choco") {
                choco install sharex
            } elseif ($global:pkgmgr -eq "winget") {
                winget install ShareX.ShareX
            }
        }

        "Krita" {
            if ($global:pkgmgr -eq "choco") {
                choco install krita
            } elseif ($global:pkgmgr -eq "winget") {
                winget install KDE.Krita
            }
        }

        "GIMP" {
            if ($global:pkgmgr -eq "choco") {
                choco install gimp
            } elseif ($global:pkgmgr -eq "winget") {
                winget install GIMP.GIMP
            }
        }

        "Inkscape" {
            if ($global:pkgmgr -eq "choco") {
                choco install inkscape
            } elseif ($global:pkgmgr -eq "winget") {
                winget install Inkscape.Inkscape
            }
        }

        #Remote

        "TeamViewer" {
            if ($global:pkgmgr -eq "choco") {
                choco install teamviewer
            } elseif ($global:pkgmgr -eq "winget") {
                winget install TeamViewer.TeamViewer
            }
        }

        "Parsec" {
            if ($global:pkgmgr -eq "choco") {
                choco install parsec
            } elseif ($global:pkgmgr -eq "winget") {
                winget install ParsecCloudInc.Parsec
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

        "Bitwarden" {
            if ($global:pkgmgr -eq "choco") {
                choco install bitwarden
            } elseif($global:pkgmgr -eq "winget") {
                winget install Bitwarden.Bitwarden
            }
        }

        "1Password" {
            if ($global:pkgmgr -eq "choco") {
                choco install 1password
            } elseif($global:pkgmgr -eq "winget") {
                winget install AgileBits.1Password
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

        "QEMU" {
            if ($global:pkgmgr -eq "choco") {
                choco install qemu
            } elseif ($global:pkgmgr -eq "winget") {
                winget install SoftwareFreedomConservancy.QEMU
            }
        }

        #Hardware info & Benchmarks

        "CPU-Z" {
            if ($global:pkgmgr -eq "choco") {
                choco install cpu-z
            } elseif ($global:pkgmgr -eq "winget") {
                winget install CPUID.CPU-Z
            }
        }

        "GPU-Z" {
            if ($global:pkgmgr -eq "choco") {
                choco install gpu-z
            } elseif ($global:pkgmgr -eq "winget") {
                winget install TechPowerUp.GPU-Z
            }
        }

        "Crystal Disk Mark" {
            if ($global:pkgmgr -eq "choco") {
                choco install crystaldiskmark
            } elseif ($global:pkgmgr -eq "winget") {
                winget install CrystalDewWorld.CrystalDiskMark
            }
        }

        "AIDA64 Extreme" {
            if ($global:pkgmgr -eq "choco") {
                choco install aida64-extreme
            } elseif ($global:pkgmgr -eq "winget") {
                winget install FinalWire.AIDA64Extreme
            }
        }

        #Other

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

        "TaskbarX" {
            if ($global:pkgmgr -eq "choco") {
                choco install taskbarx
            } elseif ($global:pkgmgr -eq "winget") {
                Write-Output "TaskbarX cannot be installed with winget"
            }
        }

        "StartIsBack" {
            if ($global:pkgmgr -eq "choco") {
                choco install startisback
            } elseif ($global:pkgmgr -eq "winget") {
                winget install StartIsBack.StartIsBack
            }
        }

        "Internet Download Manager" {
            if ($global:pkgmgr -eq "choco") {
                choco install internetdownloadmanager
            } elseif ($global:pkgmgr -eq "winget") {
                winget install Tonec.InternetDownloadManager
            }
        }

        'MS-DOS Mode for Windows 10 (Proof of Concept, made by Endermanch)' {
            MSDOSMode
        }

        "Winaero Tweaker (Chocolatey only)" {
            if ($global:pkgmgr -eq "choco") {
                choco install winaero-tweaker
            } elseif ($global:pkgmgr -eq "winget") {
                Write-Output "Winaero Tweaker cannot be installed with Winget"
            }
        }

        "iMazing" {
            if ($global:pkgmgr -eq "choco") {
                choco install imazing
            } elseif ($global:pkgmgr -eq "winget") {
                winget install DigiDNA.iMazing
            }
        }

        "Gpg4win" {
            if ($global:pkgmgr -eq "choco") {
                choco install gpg4win
            } elseif ($global:pkgmgr -eq "winget") {
                winget install gnupg.Gpg4win
            }
        }

        "Evernote" {
            if ($global:pkgmgr -eq "choco") {
                choco install evernote
            } elseif ($global:pkgmgr -eq "winget") {
                winget install evernote.evernote
            }
        }

        "Nitroless (1.0.0-a4)" {
            $nitroless = "https://github.com/Nitroless/Electron/releases/download/1.0.0-Alpha4/Nitroless.Setup.1.0.0-alpha4.exe"
            Invoke-WebRequest -Uri $nitroless -OutFile $conflocation\nitroless.exe
            Start-Process -FilePath $conflocation\nitroless.exe
        }

        "Authy Desktop" {
            if ($global:pkgmgr -eq "choco") {
                choco install authy-desktop
            } elseif ($global:pkgmgr -eq "winget") {
                winget install Twilio.Authy
            }
        }

        #Archiving

        "7-Zip" {
            if ($global:pkgmgr -eq "choco") {
                choco install 7zip
            } elseif ($global:pkgmgr -eq "winget") {
                winget install 7zip.7zip
            }
        }

        "WinRAR" {
            if ($global:pkgmgr -eq "choco") {
                choco install winrar
            } elseif ($global:pkgmgr -eq "winget") {
                winget install RARLab.WinRAR
            }
        }

        "WinZip (Winget only)" {
            if ($global:pkgmgr -eq "choco") {
                Write-Output "WinZip cannot be installed with Chocolatey"
            } elseif ($global:pkgmgr -eq "winget") {
                winget install Corel.WinZip
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

        "Disable Superfetch" {
            DisableSuperfetch
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

        "Change default explorer view to This PC" {
            SetExplorerThisPC
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

        "Disable Xbox Game DVR and Game Bar" {
            DisableXboxGameBar
        }

        "Hide People icon on the Taskbar" {
            HideTaskbarPeople
        }

        "Restore classic context menu (Windows 11 only)" {
            EnableClassicMenu
        }

        "Enable Windows 7-style volume flyout" {
            EnableClassicVolumeFlyout
        }

        "Enable Windows 7-style battery flyout" {
            EnableClassicBatteryFlyout
        }

        #BCD edit 

        "Remove entry" {
            BCDInfo
            Write-Output "`n `n"
            $removeid = Read-Host "Please enter/paste the entry identifier here (without the curly brackets)"
            bcdedit /displayorder "{$removeid}" /remove
            bcdedit /delete "{$removeid}"
            
        }

        "Set timeout" {
            $timeout = Read-Host "Please enter the countdown time (in seconds)"
            bcdedit /timeout $timeout
        }

        "Set default" {
            BCDInfo
            $id = Read-Host "Please enter/paste the entry identifier here (without the curly brackets)"
            bcdedit /default "{$id}"
        }

        "Export BCD configuration" {
            $timestamp = Get-Date -Format o | ForEach-Object { $_ -replace ":", "." }
            $exportbcd = Read-Host "Enter full path and filename of where you want to save BCD data (Default is youruserfolder\Documents\bcd-backup-timestamp"
            if ($exportbcd -eq "") {
                bcdedit /export $env:HOMEPATH\Documents\bcd-backup-$timestamp
            }
            else {
                bcdedit /export $exportbcd
            }
        }

        "Import BCD configuration" {
            $importbcd = Read-Host 'Enter full path to your ".bcd" file'
            bcdedit /import $importbcd
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

        "(Re)Enable Location Services" {
            EnableLocation
        }

        "(Re)Enable Activity History" {
            EnableActivityHistory
        }

        "(Re)Enable Superfetch" {
            EnableSuperfetch
        }

        "Hide build number on desktop" {
            HideBuildNumberOnDesktop
        }

        "Disable old context menu (Windows 11 only)" {
            DisableOldContextMenu
        }

        "Disable Windows 7-style volume flyout"{
            DisableClassicVolumeFlyout
        }

        "Disable Windows 7-style battery flyout" {
            DisableClassicBatteryFlyout
        }

        #Options
        "1) Create restore point" {
            Write-Output "Creating restore point..."
            Checkpoint-Computer -Description "BeforeWindowsToolbox" -RestorePointType "MODIFY_SETTINGS"
            Write-Output "Done"
        }

        "2) Change package manager" {
            Write-Output "WindowsToolbox is currently using $global:pkgmgr"
            $10vers = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").ReleaseId
            if($10vers -le 1803) {
                Write-Output "This option is not applicable for your Windows build"
            } else {
                $reply = Read-Host -Prompt "[W]inget Or [C]hocolatey (winget is recomended)"
                if ( $reply -match "[wW]" ) {
                    ((Get-Content -Path $conflocation\config.json -Raw) -replace 'choco','winget') | Set-Content -Path $conflocation\config.json
                } elseif ( $reply -match "[cC]" ) {
                    ((Get-Content -Path $conflocation\config.json -Raw) -replace 'winget','choco') | Set-Content -Path $conflocation\config.json
                }
                Write-Output "Package manager changed to $global:pkgmgr"
                $relaunch = Read-Host "Restart WindowsToolbox to apply changes? (y/n)"
                if ($relaunch -match "[yY]") {
                    Write-Output "WindowsToolbox will now restart"
                    & $PSScriptRoot\main.ps1
                    stop-process -id $PID
                }
            }
        }

        "3) Info" {
            Info
        }

        "4) Restart Explorer" {
            Write-Output "Killing Explorer process..."
            taskkill.exe /F /IM "explorer.exe"
            Write-Output "Restarting Explorer..."
            Start-Process "explorer.exe"
            Write-Output "Waiting for explorer to complete loading"
            Start-Sleep 10
            Write-Output "Done!"
        }

        "5) Restart" {
            $confirm = Read-Host "Are you sure you want to restart? (y/n) Remember to save your work first"
            if($confirm -eq "y") {
                Restart-Computer
            }
        }

        "6) Exit" {
            stop-process -id $PID
        }
    }
    Read-Host "Press Enter To Continue"
    Clear-Host
} 