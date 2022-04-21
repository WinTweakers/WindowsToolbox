:: https://stackoverflow.com/questions/3827567/how-to-get-the-path-of-the-batch-script-in-windows
SET scriptdir=%~dp0
powershell "& ""%scriptdir:~0,-1%\main.ps1"""
exit
