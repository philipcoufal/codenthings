# Add IP ranges to Receive connectors -Pc3PO #

add-pssnapin Microsoft.Exchange.Management.PowerShell.E2010

"***************************************"
"                                       "
" Please select the Receive Connector   "
" or 4 for the replication menu and     "
" press enter to continue.              "
"                                       "
" 1) Server Range                       "
" 2) Printers                           "
" 3) Riverbed                           "
" 4) Replication                        "
" 5) Exit                               "
"                                       "
"***************************************"

$a = Read-Host

IF ($a -eq 1)  
	{	
		$iprange = Read-Host 'Server Range: Please enter the IP addresses you would like to add (use the following format for multiple: "xxx.xxx.xx.xx," "xxx.xxx.xx.xx").'
			
			$WGHEXHT01 = Get-ReceiveConnector "WGHEXHT01\Server Range"
			$WGHEXHT01.RemoteIPRanges += $iprange
			Set-ReceiveConnector "WGHEXHT01\Server Range" -RemoteIPRanges $WGHEXHT01.RemoteIPRanges
			
			$WGHEXHT02 = Get-ReceiveConnector "WGHEXHT02\Server Range"
			$WGHEXHT02.RemoteIPRanges += $iprange
			Set-ReceiveConnector "WGHEXHT02\Server Range" -RemoteIPRanges $WGHEXHT02.RemoteIPRanges
	
			$001EXCAHT01 = Get-ReceiveConnector "001EXCAHT01\Server Range"
			$001EXCAHT01.RemoteIPRanges += $iprange
			Set-ReceiveConnector "001EXCAHT01\Server Range" -RemoteIPRanges $001EXCAHT01.RemoteIPRanges
		
			$001EXHT01 = Get-ReceiveConnector "001EXHT01\Server Range"
			$001EXHT01.RemoteIPRanges += $iprange
			Set-ReceiveConnector "001EXHT01\Server Range" -RemoteIPRanges $001EXHT01.RemoteIPRanges
			
		Write-Host "Addition completed successfully, press any key to return to shell."
		$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
	}
	
ElseIf ($a -eq 2)  
	{
		$iprange = Read-Host 'Printers: Please enter the IP addresses you would like to add (use the following format for multiple: "xxx.xxx.xx.xx," "xxx.xxx.xx.xx").'
	
			$001EXCAHT01 = Get-ReceiveConnector "001EXCAHT01\Printers"
			$001EXCAHT01.RemoteIPRanges += $iprange
			Set-ReceiveConnector "001EXCAHT01\Printers" -RemoteIPRanges $001EXCAHT01.RemoteIPRanges
		
			$001EXHT01 = Get-ReceiveConnector "001EXHT01\Printers"
			$001EXHT01.RemoteIPRanges += $iprange
			Set-ReceiveConnector "001EXHT01\Printers" -RemoteIPRanges $001EXHT01.RemoteIPRanges
		
		Write-Host "Addition completed successfully, press any key to return to shell."
		$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
	}
	
ElseIf ($a -eq 3)  
	{
		$iprange = Read-Host 'Riverbed: Please enter the IP addresses you would like to add (use the following format for multiple: "xxx.xxx.xx.xx," "xxx.xxx.xx.xx").'
			
			$001EXCAHT01 = Get-ReceiveConnector "001EXCAHT01\Riverbed"
			$001EXCAHT01.RemoteIPRanges += $iprange
			Set-ReceiveConnector "001EXCAHT01\Riverbed" -RemoteIPRanges $001EXCAHT01.RemoteIPRanges
		
			$001EXHT01 = Get-ReceiveConnector "001EXHT01\Riverbed"
			$001EXHT01.RemoteIPRanges += $iprange
			Set-ReceiveConnector "001EXHT01\Riverbed" -RemoteIPRanges $001EXHT01.RemoteIPRanges
		
		Write-Host "Addition completed successfully, press any key to return to shell."
		$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
	}

ElseIf ($a -eq 4)  
	{
	
		"******************************************************"
		"                                                      "
		" Please select the Server/Receive Connector you would "
		" like to replicate.                                   "
		"                                                      "
		"   1) WGHEXHT01\Server Range                          "
		"   2) WGHEXHT02\Server Range                          "
		"   3) 001EXCAHT01\Server Range                        "
		"   4) 001EXHT01\Server Range                          "   
		"   5) 001EXCAHT01\Printers                            "
		"   6) 001EXHT01\Printers                              "
		"   7) 001EXCAHT01\Riverbed                            "
		"   8) 001EXHT01\Riverbed                              "   
		"   9) Exit                                            "
		"                                                      "
		"******************************************************"

		$a = Read-Host
		
		IF ($a -eq 1)  
		{
		
			"*******************************************************"
			" Selection: WGHEXHT01\Server Range                     "
			" Please select the Server\Receive Connector you would  "
			" like to replicate to.                                 "
			"                                                       "
			"   1) WGHEXHT02\Server Range                           "
			"   2) 001EXCAHT01\Server Range                         "
			"   3) 001EXHT01\Server Range                           "
			"   4) Exit                                             "
			"                                                       "
			"*******************************************************"
			$a = Read-Host
			
			IF ($a -eq 1)  		
			{
				Write-Host "WARNING: THIS WILL ADD ANY ADDITIONAL CONNECTIONS FROM (WGHEXHT01\Server Range) TO (WGHEXHT02\Server Range). ENTER Y TO CONTINUE, ANY OTHER KEY TO EXIT."
				$r = Read-Host
				if ( $r -ne "Y" ) { exit }				
				$CONN = Get-ReceiveConnector "WGHEXHT02\Server Range"
				$CONN2 = Get-ReceiveConnector "WGHEXHT01\Server Range"
				$CONN.RemoteIPRanges += $CONN2.RemoteIPRanges
				Set-ReceiveConnector "WGHEXHT02\Server Range" -RemoteIPRanges $CONN.RemoteIPRanges
				"Operation Successful"
			}
			
			ElseIf ($a -eq 2)  		
			{
				Write-Host "WARNING: THIS WILL ADD ANY ADDITIONAL CONNECTIONS FROM (WGHEXHT01\Server Range) TO (001EXCAHT01\Server Range). ENTER Y TO CONTINUE, ANY OTHER KEY TO EXIT."
				$r = Read-Host
				if ( $r -ne "Y" ) { exit }				
				$CONN = Get-ReceiveConnector "001EXCAHT01\Server Range"
				$CONN2 = Get-ReceiveConnector "WGHEXHT01\Server Range"
				$CONN.RemoteIPRanges += $CONN2.RemoteIPRanges
				Set-ReceiveConnector "001EXCAHT01\Server Range" -RemoteIPRanges $CONN.RemoteIPRanges
				"Operation Successful"
			}
			
			ElseIf ($a -eq 3)  		
			{
				Write-Host "WARNING: THIS WILL ADD ANY ADDITIONAL CONNECTIONS FROM (WGHEXHT01\Server Range) TO (001EXHT01\Server Range). ENTER Y TO CONTINUE, ANY OTHER KEY TO EXIT."
				$r = Read-Host
				if ( $r -ne "Y" ) { exit }				
				$CONN = Get-ReceiveConnector "001EXHT01\Server Range"
				$CONN2 = Get-ReceiveConnector "WGHEXHT01\Server Range"
				$CONN.RemoteIPRanges += $CONN2.RemoteIPRanges
				Set-ReceiveConnector "001EXHT01\Server Range" -RemoteIPRanges $CONN.RemoteIPRanges
				"Operation Successful"
			}
			ElseIf ($a -eq 4) {Exit}
		}

		ElseIf ($a -eq 2)  
		{
		
			"*******************************************************"
			" Selection: WGHEXHT02\Server Range                     "
			" Please select the Server\Receive Connector you would  "
			" like to replicate to.                                 "
			"                                                       "
			"   1) WGHEXHT01\Server Range                           "
			"   2) 001EXCAHT01\Server Range                         "
			"   3) 001EXHT01\Server Range                           "
			"   4) Exit                                             "
			"                                                       "
			"*******************************************************"
			$a = Read-Host
			
			IF ($a -eq 1)  		
			{
				Write-Host "WARNING: THIS WILL ADD ANY ADDITIONAL CONNECTIONS FROM (WGHEXHT02\Server Range) TO (WGHEXHT01\Server Range). ENTER Y TO CONTINUE, ANY OTHER KEY TO EXIT."
				$r = Read-Host
				if ( $r -ne "Y" ) { exit }				
				$CONN = Get-ReceiveConnector "WGHEXHT01\Server Range"
				$CONN2 = Get-ReceiveConnector "WGHEXHT02\Server Range"
				$CONN.RemoteIPRanges += $CONN2.RemoteIPRanges
				Set-ReceiveConnector "WGHEXHT01\Server Range" -RemoteIPRanges $CONN.RemoteIPRanges
				"Operation Successful"
			}
			
			ElseIf ($a -eq 2)  		
			{
				Write-Host "WARNING: THIS WILL ADD ANY ADDITIONAL CONNECTIONS FROM (WGHEXHT02\Server Range) TO (001EXCAHT01\Server Range). ENTER Y TO CONTINUE, ANY OTHER KEY TO EXIT."
				$r = Read-Host
				if ( $r -ne "Y" ) { exit }				
				$CONN = Get-ReceiveConnector "001EXCAHT01\Server Range"
				$CONN2 = Get-ReceiveConnector "WGHEXHT02\Server Range"
				$CONN.RemoteIPRanges += $CONN2.RemoteIPRanges
				Set-ReceiveConnector "001EXCAHT01\Server Range" -RemoteIPRanges $CONN.RemoteIPRanges
				"Operation Successful"
			}
			
			ElseIf ($a -eq 3)  		
			{
				Write-Host "WARNING: THIS WILL ADD ANY ADDITIONAL CONNECTIONS FROM (WGHEXHT02\Server Range) TO (001EXHT01\Server Range). ENTER Y TO CONTINUE, ANY OTHER KEY TO EXIT."
				$r = Read-Host
				if ( $r -ne "Y" ) { exit }				
				$CONN = Get-ReceiveConnector "001EXHT01\Server Range"
				$CONN2 = Get-ReceiveConnector "WGHEXHT02\Server Range"
				$CONN.RemoteIPRanges += $CONN2.RemoteIPRanges
				Set-ReceiveConnector "001EXHT01\Server Range" -RemoteIPRanges $CONN.RemoteIPRanges
				"Operation Successful"
			}
			ElseIf ($a -eq 4) {Exit}
		}

		ElseIf ($a -eq 3)  
		{
		
			"*******************************************************"
			" Selection: 001EXCAHT01\Server Range                   "
			" Please select the Server\Receive Connector you would  "
			" like to replicate to.                                 "
			"                                                       "
			"   1) WGHEXHT01\Server Range                           "
			"   2) WGHEXHT02\Server Range                           "
			"   3) 001EXHT01\Server Range                           "
			"   4) Exit                                             "
			"                                                       "
			"*******************************************************"
			$a = Read-Host
			
			IF ($a -eq 1)  		
			{
				Write-Host "WARNING: THIS WILL ADD ANY ADDITIONAL CONNECTIONS FROM (001EXCAHT01\Server Range) TO (WGHEXHT01\Server Range). ENTER Y TO CONTINUE, ANY OTHER KEY TO EXIT."
				$r = Read-Host
				if ( $r -ne "Y" ) { exit }				
				$CONN = Get-ReceiveConnector "WGHEXHT01\Server Range"
				$CONN2 = Get-ReceiveConnector "001EXCAHT01\Server Range"
				$CONN.RemoteIPRanges += $CONN2.RemoteIPRanges
				Set-ReceiveConnector "WGHEXHT01\Server Range" -RemoteIPRanges $CONN.RemoteIPRanges
				"Operation Successful"
			}
			
			ElseIf ($a -eq 2)  		
			{
				Write-Host "WARNING: THIS WILL ADD ANY ADDITIONAL CONNECTIONS FROM (001EXCAHT01\Server Range) TO (WGHEXHT02\Server Range). ENTER Y TO CONTINUE, ANY OTHER KEY TO EXIT."
				$r = Read-Host
				if ( $r -ne "Y" ) { exit }				
				$CONN = Get-ReceiveConnector "WGHEXHT02\Server Range"
				$CONN2 = Get-ReceiveConnector "001EXCAHT01\Server Range"
				$CONN.RemoteIPRanges += $CONN2.RemoteIPRanges
				Set-ReceiveConnector "WGHEXHT02\Server Range" -RemoteIPRanges $CONN.RemoteIPRanges
				"Operation Successful"
			}
			
			ElseIf ($a -eq 3)  		
			{
				Write-Host "WARNING: THIS WILL ADD ANY ADDITIONAL CONNECTIONS FROM (001EXCAHT01\Server Range) TO (001EXHT01\Server Range). ENTER Y TO CONTINUE, ANY OTHER KEY TO EXIT."
				$r = Read-Host
				if ( $r -ne "Y" ) { exit }				
				$CONN = Get-ReceiveConnector "001EXHT01\Server Range"
				$CONN2 = Get-ReceiveConnector "001EXCAHT01\Server Range"
				$CONN.RemoteIPRanges += $CONN2.RemoteIPRanges
				Set-ReceiveConnector "001EXHT01\Server Range" -RemoteIPRanges $CONN.RemoteIPRanges
				"Operation Successful"
			}
			ElseIf ($a -eq 4) {Exit}
		}

		ElseIf ($a -eq 4)  
		{
		
			"*******************************************************"
			" Selection: 001EXHT01\Server Range                     "
			" Please select the Server\Receive Connector you would  "
			" like to replicate to.                                 "
			"                                                       "
			"   1) WGHEXHT01\Server Range                           "
			"   2) WGHEXHT02\Server Range                           "
			"   3) 001EXCAHT01\Server Range                         "
			"   4) Exit                                             "
			"                                                       "
			"*******************************************************"
			$a = Read-Host
			
			IF ($a -eq 1)  		
			{
				Write-Host "WARNING: THIS WILL ADD ANY ADDITIONAL CONNECTIONS FROM (001EXHT01\Server Range) TO (WGHEXHT01\Server Range). ENTER Y TO CONTINUE, ANY OTHER KEY TO EXIT."
				$r = Read-Host
				if ( $r -ne "Y" ) { exit }				
				$CONN = Get-ReceiveConnector "WGHEXHT01\Server Range"
				$CONN2 = Get-ReceiveConnector "001EXHT01\Server Range"
				$CONN.RemoteIPRanges += $CONN2.RemoteIPRanges
				Set-ReceiveConnector "WGHEXHT01\Server Range" -RemoteIPRanges $CONN.RemoteIPRanges
				"Operation Successful"
			}
			
			ElseIf ($a -eq 2)  		
			{
				Write-Host "WARNING: THIS WILL ADD ANY ADDITIONAL CONNECTIONS FROM (001EXHT01\Server Range) TO (WGHEXHT02\Server Range). ENTER Y TO CONTINUE, ANY OTHER KEY TO EXIT."
				$r = Read-Host
				if ( $r -ne "Y" ) { exit }				
				$CONN = Get-ReceiveConnector "WGHEXHT02\Server Range"
				$CONN2 = Get-ReceiveConnector "001EXHT01\Server Range"
				$CONN.RemoteIPRanges += $CONN2.RemoteIPRanges
				Set-ReceiveConnector "WGHEXHT02\Server Range" -RemoteIPRanges $CONN.RemoteIPRanges
				"Operation Successful"
			}
			
			ElseIf ($a -eq 3)  		
			{
				Write-Host "WARNING: THIS WILL ADD ANY ADDITIONAL CONNECTIONS FROM (001EXHT01\Server Range) TO (001EXCAHT01\Server Range). ENTER Y TO CONTINUE, ANY OTHER KEY TO EXIT."
				$r = Read-Host
				if ( $r -ne "Y" ) { exit }				
				$CONN = Get-ReceiveConnector "001EXCAHT01\Server Range"
				$CONN2 = Get-ReceiveConnector "001EXHT01\Server Range"
				$CONN.RemoteIPRanges += $CONN2.RemoteIPRanges
				Set-ReceiveConnector "001EXCAHT01\Server Range" -RemoteIPRanges $CONN.RemoteIPRanges
				"Operation Successful"
			}
			ElseIf ($a -eq 4) {Exit}
		}

		ElseIf ($a -eq 5)  
		{
		
			"*******************************************************"
			" Selection: 001EXCAHT01\Printers                       "
			" Please select the Server\Receive Connector you would  "
			" like to replicate to.                                 "
			"                                                       "
			"   1) 001EXHT01\Printers                               "
			"   2) Exit                                             "
			"                                                       "
			"*******************************************************"
			$a = Read-Host
			
			IF ($a -eq 1)  		
			{
				Write-Host "WARNING: THIS WILL ADD ANY ADDITIONAL CONNECTIONS FROM (001EXCAHT01\Printers) TO (001EXHT01\Printers). ENTER Y TO CONTINUE, ANY OTHER KEY TO EXIT."
				$r = Read-Host
				if ( $r -ne "Y" ) { exit }				
				$CONN = Get-ReceiveConnector "001EXHT01\Printers "
				$CONN2 = Get-ReceiveConnector "001EXCAHT01\Printers"
				$CONN.RemoteIPRanges += $CONN2.RemoteIPRanges
				Set-ReceiveConnector "001EXHT01\Printers" -RemoteIPRanges $CONN.RemoteIPRanges
				"Operation Successful"
			}
			ElseIf ($a -eq 2) {Exit}
		}

		ElseIf ($a -eq 6)  
		{
		
			"*******************************************************"
			" Selection: 001EXHT01\Printers                         "
			" Please select the Server\Receive Connector you would  "
			" like to replicate to.                                 "
			"                                                       "
			"   1) 001EXCAHT01\Printers                             "
			"   2) Exit                                             "
			"                                                       "
			"*******************************************************"
			$a = Read-Host
			
			IF ($a -eq 1)  		
			{
				Write-Host "WARNING: THIS WILL ADD ANY ADDITIONAL CONNECTIONS FROM (001EXHT01\Printers) TO (001EXCAHT01\Printers). ENTER Y TO CONTINUE, ANY OTHER KEY TO EXIT."
				$r = Read-Host
				if ( $r -ne "Y" ) { exit }				
				$CONN = Get-ReceiveConnector "001EXCAHT01\Printers "
				$CONN2 = Get-ReceiveConnector "001EXHT01\Printers"
				$CONN.RemoteIPRanges += $CONN2.RemoteIPRanges
				Set-ReceiveConnector "001EXCAHT01\Printers" -RemoteIPRanges $CONN.RemoteIPRanges
				"Operation Successful"
			}
			ElseIf ($a -eq 2) {Exit}
		}
		
		ElseIf ($a -eq 7)  
		{
		
			"*******************************************************"
			" Selection: 001EXCAHT01\Riverbed                       "
			" Please select the Server\Receive Connector you would  "
			" like to replicate to.                                 "
			"                                                       "
			"   1) 001EXHT01\Riverbed                               "
			"   2) Exit                                             "
			"                                                       "
			"*******************************************************"
			$a = Read-Host
			
			IF ($a -eq 1)  		
			{
				Write-Host "WARNING: THIS WILL ADD ANY ADDITIONAL CONNECTIONS FROM (001EXCAHT01\Riverbed) TO (001EXHT01\Riverbed). ENTER Y TO CONTINUE, ANY OTHER KEY TO EXIT."
				$r = Read-Host
				if ( $r -ne "Y" ) { exit }				
				$CONN = Get-ReceiveConnector "001EXHT01\Riverbed"
				$CONN2 = Get-ReceiveConnector "001EXCAHT01\Riverbed"
				$CONN.RemoteIPRanges += $CONN2.RemoteIPRanges
				Set-ReceiveConnector "001EXHT01\Riverbed" -RemoteIPRanges $CONN.RemoteIPRanges
				"Operation Successful"
			}
			ElseIf ($a -eq 2) {Exit}
		}

		ElseIf ($a -eq 8)  
		{
		
			"*******************************************************"
			" Selection: 001EXHT01\Riverbed                         "
			" Please select the Server\Receive Connector you would  "
			" like to replicate to.                                 "
			"                                                       "
			"   1) 001EXCAHT01\Riverbed                             "
			"   2) Exit                                             "
			"                                                       "
			"*******************************************************"
			$a = Read-Host
			
			IF ($a -eq 1)  		
			{
				Write-Host "WARNING: THIS WILL ADD ANY ADDITIONAL CONNECTIONS FROM (001EXHT01\Riverbed) TO (001EXCAHT01\Riverbed). ENTER Y TO CONTINUE, ANY OTHER KEY TO EXIT."
				$r = Read-Host
				if ( $r -ne "Y" ) { exit }				
				$CONN = Get-ReceiveConnector "001EXCAHT01\Riverbed"
				$CONN2 = Get-ReceiveConnector "001EXHT01\Riverbed"
				$CONN.RemoteIPRanges += $CONN2.RemoteIPRanges
				Set-ReceiveConnector "001EXCAHT01\Riverbed" -RemoteIPRanges $CONN.RemoteIPRanges
				"Operation Successful"
			}
			ElseIf ($a -eq 2) {Exit}
		}

		ElseIf ($a -eq 9) {Exit} 
	}

ElseIf ($a -eq 5) {Exit}