# Self-elevate the script if required
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
    if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
        $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
        Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
        Exit
    }
}

Import-Module -DisableNameChecking $PSScriptRoot\library\Write-Menu.psm1
Import-Module -DisableNameChecking $PSScriptRoot\library\WinCore.psm1
Import-Module -DisableNameChecking $PSScriptRoot\library\PrivacyFunctions.psm1
Import-Module -DisableNameChecking $PSScriptRoot\library\Tweaks.psm1
Import-Module -DisableNameChecking $PSScriptRoot\library\GeneralFunctions.psm1
Import-Module -DisableNameChecking $PSScriptRoot\library\DebloatFunctions.psm1
Import-Module -DisableNameChecking $PSScriptRoot\library\UndoFunctions.psm1

$title = "Windows Toolbox $version"
$host.UI.RawUI.WindowTitle = $title

try {
    # Check if winget is already installed
    $er = (invoke-expression "winget -v") 2>&1
    if ($lastexitcode) { throw $er }
    Write-Host "winget is already installed."
}
catch {
    # If winget is not installed. Install it from the Github release
    Write-Host "winget is not found, installing it right now."
	
    $download = "https://github.com/microsoft/winget-cli/releases/download/latest/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
    Write-Host "Dowloading latest release"
    Invoke-WebRequest -Uri $download -OutFile $PSScriptRoot\winget-latest.appxbundle
	
    Write-Host "Installing the package"
    Add-AppxPackage -Path $PSScriptRoot\winget-latest.appxbundle
}



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

    'Debloat'          = "@(
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

    'Tweaks'           = @{
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

        'UI Tweaks'     = "@(
            'Remove user folders under This PC',
            'Enable dark mode',
            'Disable Aero Shake',
            'Switch Windows With a Single Click on the Taskbar'
        )"
    }    

    'Install Apps'     = @{
        'Browsers'               = "@(
            'Firefox',
            'Google Chrome',
            'Brave',
            'Vivaldi'
        )"

        'Dev Tools'              = "@(
            'Visual Studio Code',
            'Atom',
            'Notepad++',
            'Github Desktop',
            'Github CLI',
            'Git',
            'JRE 8',
            'Python 3',
            'Python 2',
            'PuTTY',
            'Node.JS',
            'Vim',
            'Docker',
            'Windows Subsystem for Linux',
            'Hyper-V'
        )"

        'Communication Programs' = "@(
            'Discord',
            'Slack',
            'Zoom',
            'Skype'
        )"

        'Gaming/Streaming'       = "@(
            'Steam',
            'OBS Studio'
        )"
        
        'Multimedia'             = "@(
            'iTunes',
            'Spotify',
            'VLC'
        )"
    }

    'Undo Scripts'     = "@(
        '(Re)Enable Telemetry'
    )"

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
            winget install -e --id Mozilla.Firefox
        }

        "Google Chrome" {
            winget install -e --id Google.Chrome
        }

        "Brave" {
            winget install -e --id BraveSoftware.BraveBrowser
        }

        "Vivaldi" {
            winget install -e --id VivaldiTechnologies.Vivaldi
        }

        # Dev Tools

        "Visual Studio Code" {
            winget install -e --id Microsoft.VisualStudioCode
        }

        "Atom" {
            winget install -e --id GitHub.Atom
        }

        "Notepad++" {
            winget install -e --id Notepad++.Notepad++
        }

        "Github Desktop" {
            winget install -e --id GitHub.GitHubDesktop
        }

        "Github CLI" {
            winget install -e --id GitHub.cli
        }

        "Git" {
            winget install -e --id Git.Git
        }

        "JRE 8" {
            winget install -e --id Oracle.JavaRuntimeEnvironment
        }
            
        "Python 3" {
            winget install -e --id Python.Python.3
        }

        "Python 2" {
            winget install -e --id Python.Python.2
        }

        "PuTTY" {
            winget install -e --id PuTTY.PuTTY
        }

        "Node.JS" {
            winget install -e --id OpenJS.Nodejs
        }

        "Vim" {
            winget install -e --id vim.vim
        }

        "Docker" {
            winget install -e --id Docker.DockerDesktop
        }

        "Windows Subsystem for Linux" {
            InstallWSL
        }

        "Hyper-V" {
            InstallHyperV
        }

        # Communication Menu

        "Discord" {
            winget install -e --id Discord.Discord
        }

        "Slack" {
            winget install -e --id SlackTechnologies.Slack
        }

        "Zoom" {
            winget install -e --id Zoom.Zoom
        }

        "Skype" {
            winget install -e --id Microsoft.Skype
        }

        # Gaming stuff

        "Steam" {
            winget install -e --id Valve.Steam
        }
        
        "OBS Studio" {
            winget install -e --id OBSProject.OBSStudio
        }

        # Multimedia

        "iTunes" {
            winget install -e --id Apple.iTunes
        }

        "Spotify" {
            winget install -e --id Spotify.Spotify
        }

        "VLC" {
            winget install -e --id VideoLAN.VLC
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

        # Undo
        "(Re)Enable Telemetry" {
            EnableTelemetry
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