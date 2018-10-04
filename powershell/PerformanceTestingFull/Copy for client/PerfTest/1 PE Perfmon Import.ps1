#Rename this script with the .ps1 extension in order to execute it in PowerPowershell
cls

#Set server array from file - Verify that server hostnames have been added to the 'servers.txt' file
$servers = get-content servers.txt

#Optionally set server array with the following command
#$servers = ('server1', 'server2', 'server3', 'server4');

	Write-Host "Import of the Performance DataSets" -foregroundcolor "Magenta";
	Write-Host "==============================" -foregroundcolor "green";

#Import PE Perfmon template
foreach ($server in $servers) {
	Write-Host $server -foregroundcolor "green";
	logman import "PE" -s $server -xml "PE Perfmon v2.0.xml";
	Write-Host "------------------------------" -foreground "Green";
}