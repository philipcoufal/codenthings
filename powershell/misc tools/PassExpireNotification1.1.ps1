#_______________________Password Email Expiry Script v1.1 -Pc3PO________________________#

<#

Change Log:

v1.1:

-Emails the user regarding password expiration.
-Runs daily based and only pings user on 14, 7 and 1 day remaining.

#>

Try { Import-Module ActiveDirectory -ErrorAction Stop }
Catch { Write-Host "See Pc3PO..."; Break }

$Users = get-adUser -filter * -properties * |where {$_.Enabled -eq "True"} | where { $_.PasswordNeverExpires -eq $false } | where { $_.passwordexpired -eq $false }
$SS="mail.qracq.com"
$from = "helpdesk@qracq.com"

foreach ($User in $Users)
{
  $PE = Search-ADAccount -PasswordExpired
  $ADUser = Get-ADUser $User.SamAccountName
  $VPNDoc = "C:\Pc3PO\attachment\VPNAccessDocumentation.pdf"
  $To = $User.EmailAddress
  $passwordSetDate = (get-adUser $User -properties * | foreach { $_.PasswordLastSet })
  $maxPasswordAge = (Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge
  $expireson = $passwordsetdate + $maxPasswordAge
  $today = (get-date)
  $daystoexpire = (New-TimeSpan -Start $today -End $Expireson).Days
  $Sub = "Your password will expire in $daystoExpire days"
  $Sub1Day = "Your password will expire in $daystoExpire day"
  $Body ="
<p>$($ADUser.GivenName), <br><br>
Your password will expire in $daystoexpire days. To avoid losing access to your computer and email, please  follow the instructions below: <br><br>
For users in the office press CTRL-ALT-Delete on the keyboard simultaneously  and choose the <strong>Change a Password</strong> option listed in the menu. <br><br>
For users in the field, please go to the nearest office to connect directly  to the network or use a VPN connection, instructions attached, to perform the task above.<br>
If you are not in an office or connected with a VPN and attempt to change your  password, you will be locked out and unable to access the network. <br><br>
If you have any questions/concerns, please call the helpdesk at (713) 634-4646  or via email at helpdesk@qracq.com <br>
<br>
Thank you, </p>
<p>
  Information Technology Department <br>
  Quantum Resources</p>"
  $Body1Day ="
<p>$($ADUser.GivenName), <br><br>
Your password will expire in $daystoexpire day. To avoid losing access to your computer and email, please  follow the instructions below: <br><br>
For users in the office press CTRL-ALT-Delete on the keyboard simultaneously  and choose the <strong>Change a Password</strong> option listed in the menu. <br><br>
For users in the field, please go to the nearest office to connect directly  to the network or use a VPN connection, instructions attached, to perform the task above.<br>
If you are not in an office or connected with a VPN and attempt to change your  password, you will be locked out and unable to access the network. <br><br>
If you have any questions/concerns, please call the helpdesk at (713) 634-4646  or via email at helpdesk@qracq.com <br>
<br>
Thank you, </p>
<p>
  Information Technology Department <br>
  Quantum Resources</p>"

  if ($daystoexpire -eq 1)
  {
    Send-Mailmessage -smtpServer $SS -from $from -to $To -subject $Sub1Day -Body $Body1Day -Attachments $VPNDoc -BodyasHTML -Priority High
  }  
  if ($daystoexpire -eq 7)
  {
    Send-Mailmessage -smtpServer $SS -from $from -to $To -subject $Sub -Body $Body -Attachments $VPNDoc -BodyasHTML -Priority High
  }  
  if ($daystoexpire -eq 14)
  {
    Send-Mailmessage -smtpServer $SS -from $from -to $To -subject $Sub -Body $Body -Attachments $VPNDoc -BodyasHTML -Priority High
  }

If ($PE)

{   $Header = @"
<style>
TABLE {border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}
TH {border-width: 1px;padding: 3px;border-style: solid;border-color: black;background-color: #6495ED;}
TD {border-width: 1px;padding: 3px;border-style: solid;border-color: black;}
</style>
"@
	$Body = $PE | Select ,Name,AccountExpirationDate,@{Label="Manager";Expression={ (Get-ADUser (Get-ADUser $_ -Properties Manager).Manager).Name }},@{Label="Description";Expression={ (Get-ADUser $_ -Properties Description).Description }} | ConvertTo-HTML -Pre Content $Pre -Head $Header | Out-String
	$MS = @{
		To = "pcoufal@qracq.com"
		From = $From
		Subject = "Expired Passwords"
		SMTPServer = $SS
	}
		Send-MailMessage @MS -Body $Body -BodyAsHtml -Cc "pcaldwell@qracq.com"
}  
}