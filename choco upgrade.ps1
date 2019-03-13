#This script will run through the list of programs installed by choco and stop them if they are running. Then it will upgrade them.

#First, lets check if user is admin. Choco cannot work correctly without Admin priviledges. 
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`

        [Security.Principal.WindowsBuiltInRole] “Administrator”))

    {

        Write-Warning “You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!”
        Break

    }

#Pinned items in choco are items you have specifically chosen Chocolatey not to upgrade
$installed = choco list --lo
#if ($installed.Count -eq 0){echo "No programs were found installed via chocolatey."}
$pinned = choco pin list



#Removes version numbers
$installed = $installed -replace '[^a-zA-Z-]',''
$pinned = $pinned -replace '[^a-zA-Z-]',''

#Excluded programs; No sense searching for these
$excluded = @()

#Creates an array containing exlcuded programs
$excludedArray = New-Object System.Collections.ArrayList($null)
$excludedArray += $pinned
$excludedArray += $excluded


#Creates installed array
$installedArray = New-Object System.Collections.ArrayList($null)
$installedArray.AddRange($installed)

#Removes excluded items
$installedArray = $installedArray | Where-Object { $excludedArray -notcontains $_ }
echo $installedArray

#Programs to be stopped are p
$stopped = @()


#Goes through the installed programs and checks if any are running.
foreach ($installedArray in $installedArray)
{
    if((Get-Process -name $installedArray -ErrorAction SilentlyContinue) -eq $null)
    {
        #Write-Host "$installedArray not running"
    }
    else 
    {
        #Write-Host "$installedArray is running"
        Stop-Process -name $installedArray
        $stopped += $installedArray

    }
}

if ($stopped.Count -ne 0){echo "These programs were found to be running and were stopped: $stopped"}

choco upgrade all -y
