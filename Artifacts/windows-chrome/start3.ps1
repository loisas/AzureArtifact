##################################################################################################

#
# Powershell Configurations
#

# Note: Because the $ErrorActionPreference is "Stop", this script will stop on first failure.  
$ErrorActionPreference = "stop"

# Ensure that current process can run scripts. 
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force 

###################################################################################################


#
# Custom Configurations
#

$PackageInstallerFolder = Join-Path $env:ALLUSERSPROFILE -ChildPath $("PackageInstaller-" + [System.DateTime]::Now.ToString("yyyy-MM-dd-HH-mm-ss"))

# Location of the log files
$ScriptLog = Join-Path -Path $PackageInstallerFolder -ChildPath "PackageInstaller.log"


function InitializeFolders
{
    if ($false -eq (Test-Path -Path $PackageInstallerFolder))
    {
        New-Item -Path $PackageInstallerFolder -ItemType directory | Out-Null
    }
}


function WriteLog
{
    Param(
        <# Can be null or empty #> $message
    )

    $timestampedMessage = $("[" + [System.DateTime]::Now + "] " + $message) | % {  
        Write-Host -Object $_
        Out-File -InputObject $_ -FilePath $ScriptLog -Append
    }
}


InitializeFolders
WriteLog "Started"


$packages = @( 
@{title='Notepad++';url='http://download.tuxfamily.org/notepadplus/archive/6.7.5/npp.6.7.5.Installer.exe';Arguments=' /Q /S';Destination=$PackageInstallerFolder}
) 


foreach ($package in $packages) { 
		$packageName = $package.title 
		$fileName = Split-Path $package.url -Leaf 
		$destinationPath = $package.Destination + "\" + $fileName 

If (!(Test-Path -Path $destinationPath -PathType Leaf)) { 

	WriteLog "Downloading $packageName" 
	$webClient = New-Object System.Net.WebClient 
	$webClient.DownloadFile($package.url,$destinationPath) 
	} 
	}

 
#Once we've downloaded all our files lets install them. 
foreach ($package in $packages) { 
	$packageName = $package.title 
	$fileName = Split-Path $package.url -Leaf 
	$destinationPath = $package.Destination + "\" + $fileName 
	$Arguments = $package.Arguments 
	WriteLog "Installing $packageName" 


Invoke-Expression -Command "$destinationPath $Arguments" 
}