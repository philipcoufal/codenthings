PE Perfmon PowerShell Scripts v2.0

All scripts should be executed with elevated permissions

1. Add the list of servers to the 'servers.txt' file

2. Change the follwoing counters in the Jason Script located in the Report folder:
	‘Memory\Available Mbytes’ (10% of RAM) 
	‘PhysicalDisk(*)\Avg. Disk Queue Length’ (#  of disks in the array).
	
3. Change the $DestinationPath = 'D:\ProphetData\Performance\'; in the '3 PE Perfmon Stop.ps1' script

4. Run '1 PE Perfmon Import.ps1' to import the performance counter to each server from the server.txt file.

5. Once all benchmark models have been imported and jobs created and ready to be submitted, execute the '2 PE Perfmon Start.ps1' script to start logging

6. Once all jobs have completed, execute the '3 PE Perfmon Stop.ps1' script to stop logging.

The files will be copied to the PerfLog folder for each server insert in the server.txt file.

