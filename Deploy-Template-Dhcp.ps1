## Deploying Workload VMs
##      > Deploy and startup workload VMs based on a template
##
##################################################
## by Matt Brender (@mjbrender on Twitter)      ##
## with thanks to @josh_atwell for his help     ##
## Last edited 8/17/2014                        ##
##################################################
##
## Requires:
##      > You have the template "ubuntu-template" available in your vCenter
##      > $Datastore is the name of your target datastore
##      > $Folder is where you want to logically store the workloads
##      > $Cluster is the name of your target cluster
##
## Recommendations:
##      > Change $NumVMs to the number of VMs you'd like to run.
##
##
## To Run:
##      > Be on a PowerCLI commandline
##      > Connect to the target vCenter with Connect-VIServer
##      > Then run this command
##
## ... This could be much better.
##     Please fork and extend it!
##################################################



$NumVMs = 20
$DataStore = “nfs_ds1”
$VMNamePrefix = “dev-test”
$Folder = “Workloads”
$Template = “ubuntu-template”
$Cluster = “cluster1”
$OSCustSpec = “Dev-Servers”

#Deploy VMs
For ($count=1;$count -le $NumVMs; $count++) {
    $VMName = $VMNamePrefix + $count
    Get-OSCustomizationSpec | Get-OSCustomizationNICMapping | Set-OSCustomizationNICMapping -IPMode UseDhcp
    New-VM -Name $VMName -Template $Template -Datastore $DataStore -ResourcePool $Cluster -Location $Folder -RunAsync
}

#Start VMs
For ($count=1;$count -le $NumVMs; $count++) {
    $VMName = $VMNamePrefix + $count
    While ((Get-VM $VMName).Version -eq “Unknown”) {Write-Host “Waiting to start $VMName”}
    Start-VM $VMName
}
