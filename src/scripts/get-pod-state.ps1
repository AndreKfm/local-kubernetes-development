
<#
.SYNOPSIS
    .
.DESCRIPTION
    Returns the state of the specified pod 

.EXAMPLE
    C:\PS> get-pod-state.ps1 local-kubernetes-execution
    
.NOTES

    Author: Andre Kaufmann
    Date:   January 1st 2022
#>

param (
    [Parameter(Mandatory = $false)][string]$podName = "local-kubernetes-execution" # Name of the pod for which the state is returned
)
# Convert to Csv 

& { $global:__podList_supressed__ = (kubectl get pods); } *>$null

$podList = $global:__podList_supressed__;

$notFound = "NOTFOUND";

if (($null -eq $podList) -or (([string]$podlist).Length -eq 0)) {
    return $notFound;exit;
}

$csvPods = $podList.Trim() -replace '\s{2,}', ',' | ConvertFrom-Csv

$selectedPod = $csvPods | Where-Object NAME -eq "$podName" 

if ($null -eq $selectedPod) { return $notFound; exit; }

return $selectedPod.STATUS;

