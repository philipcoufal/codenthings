#Rename this script with the .ps1 extension in order to execute it in PowerPowershell

#Set server array from file - Verify that server hostnames have been added to the 'servers.txt' file
$servers = get-content servers.txt

#Optionally set server array with the following command
#$servers = ('server1', 'server2', 'server3', 'server4');

#Stop PE Perfmon data collector and collect data from remote system to a local folder performance
foreach ($server in $servers) {
	Write-Host "Stoping the Performance Measurement on host:" $server -foreground "Magenta";
	Write-Host "==============================" -foregroundcolor "green";
	logman stop "PE" -s $server;
	$SourcePath = '\\'+$server+'\c$\temp\Perflogs\'+$server+'_';
	$DestinationPath = 'C:\PerfLogs\';
	Write-Host "------------------------------" -foreground "Green";
	Write-Host "Copying performance file"  -foreground "Magenta";
	Write-Host "==============================" -foregroundcolor "green";
	Copy-Item -Path $SourcePath -Destination $DestinationPath -Recurse  

# New Section to rename the destination folder
    Rename-Item -Path $DestinationPath$server'_' -NewName $DestinationPath$server;
   	Write-Host "------------------------------" -foreground "Green";
	Write-Host "Renaming performance directory"  -foreground "Magenta";
	Write-Host "==============================" -foregroundcolor "green";

# Steps are done
	Write-Host "Done."  -foreground "Magenta";
	Write-Host "------------------------------" -foreground "Green";
}