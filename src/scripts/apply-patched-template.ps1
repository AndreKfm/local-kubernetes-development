<#
.SYNOPSIS
    .
.DESCRIPTION
    
    Patches the current pod template and applies it to Kubernetes
    so that late the sample application might be executed inside
    the pod

.EXAMPLE
    C:\PS> apply-patched-template.ps1 
    
.NOTES

    Author: Andre Kaufmann
    Date:   January 1st 2022
#>

param (
    [Parameter(Mandatory = $false)][string]$mountPath = "/debug" # Path inside container, to which the compiled executable files are mapped
)


# Generate temporary file to be used as target for patched template
$tempFile = New-TemporaryFile

$template = . $PSScriptRoot/patch-template.ps1 ./template/deploy-template.yaml ./sample-project/bin -mountPath $mountPath
Set-Content -Path $tempFile -Value $template

kubectl apply -f $tempFile

Remove-Item -Path $tempFile