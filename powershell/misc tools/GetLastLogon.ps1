<#
asdasdasdasd
#>
Function LastLogon
{
	param
	(
		[Parameter(ValueFromPipeline=$true)]
		[String]$user
	)
	$A = @()
	If(!$user)
	{
		$PSusers = Get-ADuser -filter * -properties lastlogon
		ForEach($PSuser in $PSusers)
		{
			If(($PSuser.lastlogon) -and ($PSuser.lastlogon -ne 0))
			{
				$obj = New-Object System.Object
				$obj | add-member -type NoteProperty -name Name -value $PSuser.name
				$obj | add-member -type NoteProperty -name Logon -value ([datetime]::fromfiletime($PSuser.lastlogon))
				$A += $obj
			}
		}
	}
	Else
	{
		$PSuser = Get-ADuser $user -properties lastlogon
		If($PSuser)
		{
			$obj = New-Object System.Object
			$obj | add-member -type NoteProperty -name Name -value $PSuser.name
			$obj | add-member -type NoteProperty -name Logon -value ([datetime]::fromfiletime($PSuser.lastlogon))
			$A += $obj
		}
	}
	$A
}