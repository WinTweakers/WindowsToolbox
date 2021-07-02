Import-Module -DisableNameChecking $PSScriptRoot\library\Write-Menu.psm1
Import-Module -DisableNameChecking $PSScriptRoot\library\Get-Admin.psm1

Get-Admin

$title = "Windows Toolbox 1.0.0"

$host.UI.RawUI.WindowTitle = $title


