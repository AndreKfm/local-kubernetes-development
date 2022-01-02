
<#
.SYNOPSIS
    .
.DESCRIPTION
    Patch-template will open the specified Kubernetes template file and replace
    the string constants by the input specified in the command line

.EXAMPLE
    C:\PS> patch-template.ps1 template\deploy-template.yaml d:\ d:\localpath\mysolution\ 
    
.NOTES

    Author: Andre Kaufmann
    Date:   December 30th 2021
#>



param (
     [Parameter(Mandatory = $true)][string]$templateFileName # Path and file name of template to patch
     , [Parameter(Mandatory = $true)][string]$localPathToMap # Path to be mapped inside Kubernetes
     , [Parameter(Mandatory = $false)][string]$mountPath = "/debug" # Path of mapped local folder inside Kubernetes container
     , [Parameter(Mandatory = $false)][string]$volumeName = "localdevelopment"  # Name of volume
     , [Parameter(Mandatory = $false)][string]$command = '["bash", "-c", "while sleep 5; do date;done"]' # Command which the container will permanently execute to keep it running
)

# Maps the passed local path to a wsl path to be used in 
# Docker Kubernetes deployments
function Convert-LocalToWslPath([string]$localPath) {
     if ($localPath.StartsWith("\\")) {
          Write-Error "Network paths not supported - [$localPath]";
          exit;
     }

     $resolvedPath = Resolve-Path $localPath
     $path = ($resolvedPath.Path).Replace('\', '/'); # Use unix compatible slashes

     $driveReg = "(?<drive>[A-Za-z]:).*";

     $driveMatch = $path -match $driveReg
     if (!$driveMatch) {
          Write-Error "Couldn't extract drive name from [$localPath]"
          exit;
     }

     # We need to extract drive character from current path 
     # e.g.: "d:\path" -> "d"

     $drive = [string]$Matches["drive"]
     $driveCharacter = $drive.Replace(':', '').ToLower();

     $path = $path.Replace($drive, $driveCharacter);

     return $path;
}

# Loads the content of the specified file and returns content as string
function Get-TemplateContent($fileName) {
     if (!(Test-Path $fileName -PathType Leaf)) {
          Write-Error "Template file [$fileName] does not exist";
          exit;
     }
     $templateContent = Get-Content -Path $fileName -Raw
     return $templateContent;
}


# Replace in content all elements of replacementSet named
# array entries [0] converted to uppercase value : name -> *NAME*     
# by array entries[1]
function Update-Template([string]$content, $replacement) {
     foreach ($elem in $replacement) {
          $name = "*$(([string]$elem[0]).ToUpper())*"
          $value = $elem[1];
          $content = $content.Replace($name, $value);
     }
     return $content;
}

$templateContent = Get-TemplateContent $templateFileName
$wslPath = Convert-LocalToWslPath $localPathToMap
#$newTemplate = Update-Template $templateContent $wslPath $volumeName $command
$replacement = @( 
     @('hostPath'  ; $wslPath), # *HOSTPATH*
     @('volumeName'; $volumeName.ToLowerInvariant()), # *VOLUMENAME*
     @('command'   ; $command), # *COMMAND*
     @('mountPath' ; $mountPath)                      # *MOUNTPATH*
)

Write-Verbose "Patch list: $replacement"
$newTemplate = Update-Template $templateContent $replacement
return $newTemplate;