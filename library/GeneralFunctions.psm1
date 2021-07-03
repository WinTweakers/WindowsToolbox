##General functions

function Exit {
    stop-process -id $PID
}

function Restart {
    Restart-Computer
}

function Info {
    Write-Output "Windows Toolbox"
    Write-Output "Only the remove default apps script has a config (located at config.ps1), you have to edit the rest to your liking beforehand."
	Write-Output "Only Windows 10 is supported, however we are testing this on Windows 11"
	Write-Output "There is no undo, all scripts are provided AS-IS and you use them at your own risk"
    Write-Output "Navigation: Use the arrow keys to navigate, Enter to select and Esc to go back"
}