
<#
.SYNOPSIS
    .
.DESCRIPTION
    Creates a new pod if not exist - otherwise will reuse the current one and 
    execute the sample application directly under Docker Kubernetes

.EXAMPLE
    C:\PS> deploy-and-run.ps1 
    
.NOTES

    Author: Andre Kaufmann
    Date:   January 1st 2022
#>

param (
    [Parameter(Mandatory = $false)][string]$podName = "local-kubernetes-execution" # Name of the pod to deploy and run application in
    , [Parameter(Mandatory = $false)][string]$configuration = "Debug" # Configuration of sample project to build and run (e.g. Debug or Release)
    , [Parameter(Mandatory = $false)][switch]$skipBuild               # If set will skip building of sample project
    , [Parameter(Mandatory = $false)][switch]$skipDependencyCheck     # If set will skip check for dependencies (e.g. Docker, Kubernetes)
    , [Parameter(Mandatory = $false)][switch]$skipPodExistsCheck      # If set will skip check for existing pod
    , [Parameter(Mandatory = $false)][switch]$skipPodCorrectMapping   # If set will skip check for pod using correct mapping
    , [Parameter(Mandatory = $false)][string]$mountPath = "/debug" # Path inside container, to which the compiled executable files are mapped
    , [Parameter(Mandatory = $false)][string]$project = "$PSScriptRoot\sample-project\sample-project.csproj" # Project to build
)


function Remove-Pod($podName) {
    kubectl delete pod $podName --grace-period=0 --force
    Write-Verbose "Deleted pod = $podName to use new mapping $mountPath"
}

function Test-Dependencies {
    if ($skipDependencyCheck -eq $false) {
        $dependencies = . $PSScriptRoot/scripts/check-dependencies.ps1

        if ($dependencies -eq $false) {
            $cont = Read-Host "Dependencies are not completely matching, do you want to continue anyways - y/n?"        
            if ($cont -eq 'n') { exit; }
        }
        else {
            Write-Verbose "Dependencies are ok"      
        }
    }
}

function Get-PodStateAndTestValidMapping($podName) {
    if ($skipPodCorrectMapping -eq $false) {
        $state = . $PSScriptRoot/scripts/get-pod-state.ps1 $podName 

        if ($state -eq "RUNNING") {
            Write-Verbose "Testing for correct mount path $mountPath"
            $testCommand = 'test -d ' + $mountPath + ' && echo "exist" || echo "not-found"';
            $testExist = kubectl exec --stdin --tty $podName -- /bin/bash -c $testCommand;
            Write-Verbose "$mountPath test result: $testExist"
            if ($testExist -ne "exist") {
                # The pod uses a different mapped folder - delete it and set state appropriately
                Remove-Pod $podName;
                $state = . $PSScriptRoot/scripts/get-pod-state.ps1 $podName;
            }
        }
        return $state;
    }
    else { 
        return "RUNNING"; # Fake because skipped is activated 
    }

}

function Update-PodIfNecessaryCreateNew($podName, $state, $mountPath) {
    if ($skipPodExistsCheck -eq $false) {
        # Only redeploy if state is not running
        if ($state -ne "RUNNING") {
            if ($state -ne "NOTFOUND") {
                Remove-Pod $podName;
            }
    
            Write-Verbose "Create new pod"
            . $PSScriptRoot/scripts/apply-patched-template.ps1 -mountPath $mountPath
    
            $state = $null; 
            # Wait till pod is in running state
            while ($state -ne "RUNNING") {
                Start-Sleep -Milliseconds 500
                Write-Host "Waiting till pod is in running state: current state = $state"
                $state = . $PSScriptRoot/scripts/get-pod-state.ps1 $podName 
            }
        }
    }
}

function Build-Project($project, $configuration) {
    if ($skipBuild -eq $false) {
        Write-Verbose "Calling build script: -project $project -configuration $configuration"
        & { $global:__output_suppressed__ = . $PSScriptRoot/scripts/build-sample-project.ps1 -project $project -configuration $configuration } *>$null
        Write-Verbose "Build result: $global:__output_suppressed__"
    }
} 

function Start-SampleProject($configuration, $podName, $mountPath) {
    Write-Verbose "Start project: config = $configuration pod name = $podName  mount path = $mountPath"
    . $PSScriptRoot/scripts/run-sample-project.ps1 -configuration $configuration -podName $podName -mountPath $mountPath
}

function Main() {

    Test-Dependencies;
    Build-Project $project $configuration
    $state = Get-PodStateAndTestValidMapping $podName;
    Update-PodIfNecessaryCreateNew $podName $state $mountPath;
    Start-SampleProject $configuration $podName $mountPath
}

Main;