
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
$pods = (kubectl get pods).Trim() -replace '\s{2,}', ',' | ConvertFrom-Csv

$selectedPod = $pods | Where-Object NAME -eq "$podName" 

if ($null -eq $selectedPod) { return "NOTFOUND"; exit; }

return $selectedPod.STATUS;

