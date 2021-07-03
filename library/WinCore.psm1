function New-FolderForced {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
		[Parameter(Position = 0, Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
		[string]
        $Path
    )

    process {
        if (-not (Test-Path $Path)) {
            Write-Verbose "-- Creating full path to:  $Path"
            New-Item -Path $Path -ItemType Directory -Force
        }
    }
}

function InstallChoco {
    $testchoco = powershell choco -v
    if(-not($testchoco)){
        Write-Output "Seems Chocolatey is not installed, installing now"
        Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    }
    else{
        Write-Output "Chocolatey Version $testchoco is already installed"
    }
}
