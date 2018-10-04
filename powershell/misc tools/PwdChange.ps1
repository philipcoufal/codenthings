clear 
$PLSValue = -1 
$ObjFilter = "(&(objectCategory=person)(objectCategory=User))"  
    $objSearch = New-Object System.DirectoryServices.DirectorySearcher  
    $objSearch.PageSize = 15000  
    $objSearch.Filter = $ObjFilter   
    $objSearch.SearchRoot = "LDAP://OU=USATank,DC=local,DC=tfwarren,DC=com"  
    $AllObj = $objSearch.FindAll()
    foreach ($Obj in $AllObj)  
           { 
            $objItemS = $Obj.Properties 
            $UserN = $objItemS.name 
            $UserDN = $objItemS.distinguishedname 
            $user = [ADSI] "LDAP://$userDN" 
            $user.psbase.invokeSet("pwdLastSet",$PLSValue) 
            Write-host -NoNewLine "Modifying $UserN Properties...." 
            $user.setinfo() 
            Write-host "Done!" 
            } 