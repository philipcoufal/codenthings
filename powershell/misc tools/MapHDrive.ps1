Import-Module activedirectory

Net use H: /delete /Yes
$User = $env:username
$Dir = Get-ADUser $User -properties HomeDirectory | Select HomeDirectory
net use H: $Dir.homedirectory /Persistent:Yes



