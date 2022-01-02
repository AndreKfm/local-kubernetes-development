
<#
.SYNOPSIS
    .
.DESCRIPTION
    Builds the sample project 

.EXAMPLE
    C:\PS> build-sample-project.ps1
    C:\PS> build-sample-project.ps1 Debug
    
.NOTES

    Author: Andre Kaufmann
    Date:   January 1st 2022
#>

param (
    [Parameter(Mandatory = $false)][string]$project = "$PSScriptRoot\..\sample-project\sample-project.csproj" # Project to build
    , [Parameter(Mandatory = $false)][string]$configuration = "Debug" # # Configuration of sample project to build (e.g. Debug or Release)
)


Write-Verbose "Calling dotnet build: config = $configuration project = $project"

. dotnet build -v q -c $configuration $project