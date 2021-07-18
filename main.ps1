# Self-elevate the script if required
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
    if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
        $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
        Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
        Exit
    }
}

Set-ExecutionPolicy Unrestricted -Scope CurrentUser
ls -Recurse *.ps*1 | Unblock-File

Import-Module -DisableNameChecking .\library\Write-Menu.psm1
Import-Module .\library\WinCore.psd1
Import-Module -DisableNameChecking .\library\PrivacyFunctions.psm1
Import-Module -DisableNameChecking .\library\Tweaks.psm1
Import-Module -DisableNameChecking .\library\GeneralFunctions.psm1
Import-Module -DisableNameChecking .\library\DebloatFunctions.psm1
Import-Module -DisableNameChecking .\library\UndoFunctions.psm1

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
	
    $download = "https://github.com/microsoft/winget-cli/releases/download/v1.0.11692/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
    Write-Host "Dowloading latest release"
    Invoke-WebRequest -Uri $download -OutFile $PSScriptRoot\winget-latest.appxbundle
	
    Write-Host "Installing the package"
    Add-AppxPackage -Path $PSScriptRoot\winget-latest.appxbundle
}

Clear-Host

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

    'Undo Scripts' = "@(
        '(Re)Enable Telemetry'
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
            winget install Mozilla.Firefox
        }

        "Google Chrome" {
            winget install Google.Chrome
        }

        "Brave" {
            winget install BraveSoftware.BraveBrowser
        }

        "Vivaldi" {
            winget install VivaldiTechnologies.Vivaldi
        }

        # Dev Tools

        "Visual Studio Code" {
            winget install Microsoft.VisualStudioCode
        }

        "Atom" {
            winget install GitHub.Atom
        }

        "Notepad++" {
            winget install Notepad++.Notepad++
        }

        "Github Desktop" {
            winget install GitHub.GitHubDesktop
        }

        "Github CLI" {
            winget install GitHub.cli
        }

        "Git" {
            winget install Git.Git
        }

        "JRE 8" {
            winget install Oracle.JavaRuntimeEnvironment
        }
            
        "Python 3" {
            winget install Python.Python.3
        }

        "Python 2" {
            winget install Python.Python.2
        }

        "PuTTY" {
            winget install PuTTY.PuTTY
        }

        "Node.JS" {
            winget install OpenJS.Nodejs
        }

        "Vim" {
            winget install vim.vim
        }

        "Docker" {
            winget install Docker.DockerDesktop
        }

        "Windows Subsystem for Linux" {
            InstallWSL
        }

        "Hyper-V" {
            InstallHyperV
        }

        # Communication Menu

        "Discord" {
            winget install Discord.Discord
        }

        "Slack" {
            winget install SlackTechnologies.Slack
        }

        "Zoom" {
            winget install Zoom.Zoom
        }

        "Skype" {
            winget install Microsoft.Skype
        }

        # Gaming stuff

        "Steam" {
            winget install Valve.Steam
        }
        
        "OBS Studio" {
            winget install OBSProject.OBSStudio
        }

        # Multimedia

        "iTunes" {
            winget install Apple.iTunes
        }

        "Spotify" {
            winget install Spotify.Spotify
        }

        "VLC" {
            winget install VideoLAN.VLC
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
} until($mainMenu -eq "ForeverLoop")
