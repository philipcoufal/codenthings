######## Combination Expiration Script -PC3PO #########

<#

This simple script serves two purposes. The first is to notify the system 
administrators of expiring accounts that are approacing within a certain number of days.
The second purpose is to notify the users if they are approaching an expiring expiration date.

#>

######## Begin Account expiration script ########

#Needed Modules :) Affirm active directory and RSAT tools are installed on script host.
	Try { Import-Module ActiveDirectory -ErrorAction Stop }
	Catch { Write-Host "See PC3PO"; Break }
	
	$EU = Search-ADAccount -AccountExpiring -TimeSpan "8"

get-aduser -ldapfilter "(&(&(objectCategory=user)(userAccountControl=512)))" | Select-Object samAccountName,mail,PasswordStatus | Where-Object {$_.PasswordStatus -ne "Password never expires" -and $_.PasswordStatus -ne "Expired" -and $_.PasswordStatus -ne "User must change password at next logon." -and $_.mail -ne $null} |  

ForEach-Object { 
  $today = Get-Date 
  $logdate = Get-Date -format yyyyMMdd 
  $samaccountname = $_.samAccountName 
  $mail = $_.mail  
  $passwordstatus = $_.PasswordStatus 
  $passwordexpiry = $passwordstatus.Replace("Expires at: ","") 
  $passwordexpirydate = Get-Date $passwordexpiry 
  $daystoexpiry = ($passwordexpirydate - $today).Days 
  $smtpserver = "mail.qracq.com" 
  $emailFrom = "pcoufal@qracq.com" 
  $body = "Please change your password to prevent loss of access to your account`n`n" 
  $body += "If you are unable to change your password, please contact the help desk" 
  if ($daystoexpiry -lt 5 ) { 
    $emailTo = "$mail" 
    $subject = "Your Network password will expire in $daystoexpiry day(s) please change your password."     
    Send-MailMessage -To $emailTo -From $emailFrom -Subject $subject -Body $body -SmtpServer $smtpserver 
  } 
}	

######## Begin Acct Expiration Script :D ########
If ($EU)
{   $Header = @"
<style>
TABLE {border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}
TH {border-width: 1px;padding: 3px;border-style: solid;border-color: black;background-color: #6495ED;}
TD {border-width: 1px;padding: 3px;border-style: solid;border-color: black;}
</style>
"@
	$Sub = "Accounts expiring in 8 Days"
	$Body = $EU | Select SamAccountName,Name,AccountExpirationDate @{Label="Manager";Expression={ (Get-ADUser (Get-ADUser $_ -Properties Manager).Manager).Name }},@{Label="Description";Expression={ (Get-ADUser $_ -Properties Description).Description }} | ConvertTo-HTML -Pre Content $Pre -Head $Header | Out-String
	$MS = @{
		To = "pcoufal@qracq.com"
		From = "pcoufal@qracq.com"
		Subject = $Sub
		SMTPServer = "mail.qracq.com"
		}
		Send-MailMessage @MS -Body $Body -BodyAsHtml
}