##General functions

$version = "1.0.0-beta.1"

function Exit {
    stop-process -id $PID
}

function Restart {
    Restart-Computer
}

function Info {
    Write-Output "Windows Toolbox $version"
    Write-Output "None of the scripts have configs (for now), you have to edit them to your liking beforehand."
	Write-Output "Only Windows 10 is supported, however support for Windows 11 is comming soonTM"
	Write-Output "There is no undo (for now), all scripts are provided AS-IS and you use them at your own risk"
    Write-Output "Navigation: Use the arrow keys to navigate, Enter to select and Esc to go back"
    Write-Output ""
    Write-Output ""
    Read-Host "Press Enter to continue"
}