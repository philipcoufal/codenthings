#_______________________Account Expiration Script v1.2 -Pc3PO________________________#

<#

Change Log:

v1.2:
- Revert to master ticket system.
- Email to Joey and Phillip for already expired accounts.

v1.1:
-Emails the user regarding acct expiration.
-Emails individual tickets to the helpdesk vs one master.

#>

Param (
    [string]$TS = "6",
    [string]$HD = "helpdesk@qracq.com",
    [string]$From = "pcoufal@qracq.com",
    [string]$SS = "mail.qracq.com"
)

Try { Import-Module ActiveDirectory -ErrorAction Stop }
Catch { Write-Host "See Pc3PO..."; Break }

$EU = Search-ADAccount -AccountExpiring -TimeSpan $TS
$UE = Search-ADAccount -AccountExpired -UsersOnly | Where {$_.DistinguishedName -notlike "*OU=Vendor Support Accounts,OU=Users,OU=Quantum Resources Management,DC=quantumep,DC=Com*" -and $_.DistinguishedName -notlike "*OU=ServiceAccounts,OU=QRM-Infrastructure,DC=quantumep,DC=com*"-and $_.DistinguishedName -notlike "*OU=DisabledAccounts,OU=Quantum Resources Management,DC=quantumep,DC=com*" -and $_.DistinguishedName -notlike "*OU=DisabledAccounts,OU=QRM-Infrastructure,DC=quantumep,DC=com*" -and $_.DistinguishedName -notlike "*OU=Auditors,OU=Users,OU=Quantum Resources Management,DC=quantumep,DC=com*" -and $_.DistinguishedName -notlike "*OU=Remote Support Accounts,OU=Users,OU=Quantum Resources Management,DC=quantumep,DC=com*"}

ForEach ($User in $EU)
{   $ADUser = Get-ADUser $User.SamAccountName -Properties EmailAddress
    $Body = @"
<p>$($ADUser.GivenName),<br><br> 
This email is being sent to remind you that your account is expiring on $($User.AccountExpirationDate) and your access to our systems will stop  functioning at that time.<br><br>
Please contact the helpdesk at (713)634-4646 or via email  at helpdesk@qracq.com as soon as possible in order to extend the expiration date for an additional  30, 60, or 90 days. <br><br> 
Thank you,</p><p>Information Technology Department <br> Quantum Resources</p>
"@
    $SMTPSettings = @{
        To = $ADUser.EmailAddress
        From = $HD
        Subject = "Your account is about to expire"
        SMTPServer = $SS
    }
    Send-MailMessage @SMTPSettings -Body $Body -BodyAsHTML -Priority High
}

If ($UE)
{   $Header = @"
<style>
TABLE {border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}
TH {border-width: 1px;padding: 3px;border-style: solid;border-color: black;background-color: #6495ED;}
TD {border-width: 1px;padding: 3px;border-style: solid;border-color: black;}
</style>
"@
	$Body = $UE | Select SamAccountName,Name,AccountExpirationDate,@{Label="Manager";Expression={ (Get-ADUser (Get-ADUser $_ -Properties Manager).Manager).Name }},@{Label="Description";Expression={ (Get-ADUser $_ -Properties Description).Description }} | ConvertTo-HTML -Pre Content $Pre -Head $Header | Out-String
	$MS = @{
		To = "joey.rappaport@qracq.com"
		From = $From
		Subject = "Expired Accounts"
		SMTPServer = $SS
	}
		Send-MailMessage @MS -Body $Body -BodyAsHtml -Cc "pcastleberry@qracq.com" 
}

If ($EU)
{   $Header = @"
<style>
TABLE {border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}
TH {border-width: 1px;padding: 3px;border-style: solid;border-color: black;background-color: #6495ED;}
TD {border-width: 1px;padding: 3px;border-style: solid;border-color: black;}
</style>
"@
	$Body = $EU | Select Name,AccountExpirationDate,@{Label="Manager";Expression={ (Get-ADUser (Get-ADUser $_ -Properties Manager).Manager).Name }},@{Label="Description";Expression={ (Get-ADUser $_ -Properties Description).Description }} | ConvertTo-HTML -Pre Content $Pre -Head $Header | Out-String
	$MS = @{
		To = $HD
		From = $From
		Subject = "Accounts Expiring Within 6 days"
		SMTPServer = $SS
	}
		Send-MailMessage @MS -Body $Body -BodyAsHtml
}