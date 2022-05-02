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
$documents = $env:USERPROFILE + "\\Documents"
Write-Output "Downloading WindowsToolbox..."
Invoke-WebRequest -Uri "https://github.com/WinTweakers/WindowsToolbox/archive/refs/heads/main.zip" -OutFile $documents\WindowsToolbox.zip
Write-Output "Extracting WindowsToolbox..." 
Expand-Archive -LiteralPath $documents\WindowsToolbox.zip -DestinationPath $documents -Force
Remove-Item -Path "$documents\WindowsToolbox.zip" -Force
Set-ExecutionPolicy Unrestricted -Scope CurrentUser
Get-ChildItem -Recurse $documents\WindowsToolbox-main\*.ps*1 | Unblock-File
Start-Process -FilePath $documents\WindowsToolbox-main\WindowsToolbox.cmd 