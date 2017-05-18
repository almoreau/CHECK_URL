# Pilotage F5 PRD

param([String[]] $server, [String] $action)

if ((!$server) -or (!$action)) { Write-Host("Usage : F5pilot_PRD [node] [enable/disable/status]") -foreground "red" ; exit }
if (($action -ne "enable") -and ($action -ne "disable") -and ($action -ne "status")) { Write-Host("Usage PRD : F5pilot_PRD [node] [enable/disable/status]") -foreground "red" ; exit }

if (($server) -eq "SERVERNAME") { $node = "IP_ADDRESS%304"; $serverOk = "Ok"}
if (($server) -eq "SERVERNAME") { $node = "IP_ADDRESS%304"; $serverOk = "Ok"}
if (($server) -eq "SERVERNAME") { $node = "IP_ADDRESS%304"; $serverOk = "Ok"}
if (($server) -eq "SERVERNAME") { $node = "IP_ADDRESS%304"; $serverOk = "Ok"}
if (($server) -eq "SERVERNAME") { $node = "IP_ADDRESS%304"; $serverOk = "Ok"}
if (($server) -eq "SERVERNAME") { $node = "IP_ADDRESS%304"; $serverOk = "Ok"}
if (($server) -eq "SERVERNAME") { $node = "IP_ADDRESS%302"; $serverOk = "Ok"}
if (($server) -eq "SERVERNAME") { $node = "IP_ADDRESS%302"; $serverOk = "Ok"}
if ($serverOk -ne "Ok") { Write-Host("Usage : F5Pilot_PRD [node] [enable/disable/status]") -foreground "red" ; exit }

#Initialize Snapin
if ( (Get-PSSnapin | Where-Object { $_.Name -eq "iControlSnapIn"}) -eq $null ){
    Add-PSSnapIn iControlSnapIn
}
#Setup credentials
$User = "USER"
$Password = "PWD"

# BigIP de PRD
$BigIP = "IP_BIGIP_PRD"
# Connect to the BigIP and get an iControl Handle
$Success = Initialize-F5.iControl -HostName $BigIP -Username $User -Password $Password
# $Success = Initialize-F5.iControl -HostName $BigIP -Credentials (Get-Credential)
$F5 = Get-F5.iControl
# Get the partition list
$f5partitions = $f5.ManagementPartition
# Set the active partition
$f5partitions.set_active_partition("Partition_WebServices")
switch ($action) 
    { 
       status { Get-F5.LTMNodeAddress -Node $node | select Name, Enabled } 
       enable { Enable-F5.LTMNodeAddress -Node $node | select Name, Enabled } 
       disable { Disable-F5.LTMNodeAddress -Node $node | select Name, Enabled } 
    }




