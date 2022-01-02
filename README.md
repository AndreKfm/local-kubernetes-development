# Local-Kubernetes-Development
Sample project and scripts for Visual Studio Docker local Kubernetes development

## TL;DR: Quickstart 

!! Prerequisites: Docker (4.3.2) with activated Kuberntes and activated WSL mode, Windows 10 or higher and Powershell/Core 7 or higher


 - Execute script in powershell: create-pod-and-run-app.ps1 in folder src
 - Or load Visual Studio solution src\sample-project\sample-project.sln and run with CTRL-F5

## Description

Kubernetes pods running under Docker Desktop for Windows can use volumes, which are directly mapped to a Windows local folder. Therefore the compiled binaries of a C# project are directly visible inside the Kubernetes pod and can be directly started inside the pod after compilation, without the need to build a container image and load it into Kubernetes.
This allows the same fast development cycles as in local projects.

## Content

| Type | Name | Description |
| :---- | :---- | :---- |
 | Directory | sample-project | Sample Visual Studio 2022 project. Starting this project with CTRL-F5 and activated launch setting "Run under Kubernetes" (default) starts the project directly in an automatically deployed Docker Kubernetes pod.
  | Directory | scripts | Contains multiple helper Powershell scripts to build, deploy and run the sample or other visual studio projects inside a Docker Kubernetes pod
  | Directory | template | Kubernetes yaml template with variables. Will be patched by the scripts and applied afterwards to local Kubernetes to create a pod, in which the sample project binaries are executed
  | Script | all scripts | All powershell scripts contain short descriptions and parameter help. Just call help -cmd- to get the help of each single command
  | Script | scripts/apply-patched-template.ps1 | Patches the template writes the patched content to a temporary template and applies the temporary template to Kubernetes to run the pod
  | Script | scripts/build-sample-project.ps1 | Builds the sample project with the specified configuration (Release / Debug)
  | Script | scripts/check-dependencies.ps1 | Checks the needed dependencies for availability. Currently Docker, Kubernetes and the Kubernetes context set to docker-desktop. Versions and Powershell dependencies are not checked
  | Script | scripts/get-pod-state.ps1 | Returns the state of the specified pod. Will be used to omit deployment of a new pod if the old one is already running with correct settings
  | Script | scripts/patch-template.ps1 | Patches the template with the specified parameters and returns the patched files content
  | Script | scripts/run-sample-project.ps1 | Runs the compiled executable inside the Kubernetes pod 
   
