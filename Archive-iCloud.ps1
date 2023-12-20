[CmdletBinding()]
param (
    [Parameter(mandatory=$false)]
    [string]$Source = "C:\Users\Matt\Desktop\iCloud Photos.zip",
    [char]$InternalDrive = "F",
    [string]$Destination = "\archives\camera-roll\2023",
    [string]$ExternalDriveName = "Data-Backup"
)
$ErrorActionPreference = "Stop"

. F:/projects/scripts/Add-Dependency.ps1
Add-Dependency "C:\Program Files\7-Zip" "7z"

# for brevity's sake, the backup directories are stored in $x (external) and $n (internal)
$ExternalDrive = (Get-Volume -FriendlyName $ExternalDriveName).DriveLetter
$x = "$($ExternalDrive):$($Destination)"
$n = "$($InternalDrive):$($Destination)"

# Check for photos folders; create them if they don't exist
if(-Not (Test-Path "$x")) { New-Item "$x" -ItemType Directory }
if(-Not (Test-Path "$n")) { New-Item "$n" -ItemType Directory }

# extract source
7z e "$Source" -o"$n"
7z e "$Source" -o"$x"

# verify parity between the two backup locations.
if((Compare-Object -ReferenceObject (Get-ChildItem "$n") -DifferenceObject (Get-ChildItem "$x") | Measure-Object).count -ne 0) {
    Write-Warning "Discrepancies found between backup locations. Opening WinMerge to inspect."
    Add-Dependency "C:\Program Files\WinMerge" "WinMergeU"
    WinMergeU "$n" "$x" /r /fl   # Open Winmerge to manually check/copy over
}
else {Write-Host "No discrepencies found between $n and $x."}

Remove-Item -Path $Source -Confirm