#_______________________Chrome Password Manager -Pc3PO________________________#

$val = Get-ItemProperty -Path hklm:SOFTWARE\Policies\Google\Chrome -Name "PasswordManagerEnabled"
if($val.PasswordManagerEnabled -ne 0)
{
 set-itemproperty -Path hklm:SOFTWARE\Policies\Google\Chrome -Name "PasswordManagerEnabled" -value 1
}