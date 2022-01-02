
<#
.SYNOPSIS
    .
.DESCRIPTION
    Checks dependencies needed to run the sample project.
     - Docker
     - Kubernetes
     Returns either $true or $false

.EXAMPLE
    C:\PS> check-dependencies
    
.NOTES

    Author: Andre Kaufmann
    Date:   December 30th 2021
#>



function Test-DockerDependency() {
     
     & { docker version } *>$null
     return $?;
}

function Test-KubernetesDependency() {
     
     & { kubectl version } *>$null
     return $?;
}

function Test-KubernetesDockerDesktopDependency() {
     
     $context = kubectl config current-context;
     return (([string]$context).ToLowerInvariant() -eq "docker-desktop");
}


if ((Test-DockerDependency) -eq $false) {
     Write-Error "Docker is not running - please install / run Docker Desktop (tested with version Docker Desktop 4.3.2)"
     return $false;
}

if ((Test-KubernetesDependency) -eq $false) {
     Write-Error "Kubernetes is not running - please activate Kubernetes in Docker settings"
     return $false;
}

if ((Test-KubernetesDockerDesktopDependency) -eq $false) {
     $output = "Kubernetes contexts is not docker-desktop - trying to continue anyways";
     for ($cnt = 0; $cnt -le 3; $cnt++) {
          Write-Warning $output; # Multiple outputs - easier to see in console
     }
}


return $true;
