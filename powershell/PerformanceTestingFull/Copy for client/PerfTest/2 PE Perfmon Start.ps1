#Rename this script with the .ps1 extension in order to execute it in PowerPowershell

#Set server array from file - Verify that server hostnames have been added to the 'servers.txt' file
$servers = get-content servers.txt

	Write-Host "Starting the Performance Measurement" -foreground "Magenta";
	Write-Host "==============================" -foregroundcolor "green";

#Optionally set server array with the following command
#$servers = ('server1', 'server2', 'server3', 'server4');

#Start PE Perfmon data collector
foreach ($server in $servers) {
	Write-Host $server -foreground "Green";
	logman start "PE" -s $server;
	Write-Host "------------------------------" -foreground "Green";
}