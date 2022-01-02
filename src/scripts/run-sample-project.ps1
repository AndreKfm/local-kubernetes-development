
<#
.SYNOPSIS
    .
.DESCRIPTION
    Executes a previously deployed and compiled sample project

.EXAMPLE
    C:\PS> run-sample-project.ps1
    
.NOTES

    Author: Andre Kaufmann
    Date:   January 1st 2022
#>

param (
    [Parameter(Mandatory = $false)][string]$configuration = "Debug" # Configuration to run - commonly Debug or Release
    , [Parameter(Mandatory = $false)][string]$podName = "local-kubernetes-execution" # Name of the pod to run the application in (must be a correctly mapped pod)
    , [Parameter(Mandatory = $false)][string]$mountPath = "/debug" # Path inside container, to which the compiled executable files are mapped
    , [Parameter(Mandatory = $false)][switch]$skipKillProcess  # If set checks if already processes are existing and killing them before will be skipped (dangerous)
)

# We have to wait for all processes (dotnet) to be terminated, otherwise we could risk that 
# start of the application might fail because pkill will kill dotnet processes starting (for what reason ever)
$cmd = "kubectl exec --stdin --tty $podName -- /bin/bash -c 'pkill -e dotnet;  while pgrep -u root dotnet > /dev/null; do sleep 1; done; dotnet /$mountPath/$configuration/net6.0/sample-project.dll; pkill dotnet'"

if ($skipKillProcess -eq $true) {
    $cmd = "kubectl exec --stdin --tty $podName -- /bin/bash -c 'dotnet /$mountPath/$configuration/net6.0/sample-project.dll; pkill dotnet'"
}

Write-Verbose "Starting app in Kubernetes: $cmd"
Invoke-Expression -Command $cmd