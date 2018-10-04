Add-Type -AssemblyName System.Windows.Forms
$result = [System.Windows.Forms.MessageBox]::Show('Do you want to begin the transfer?', 'Copy2RO', 'YesNo', 'Warning')
$wshell = New-Object -ComObject Wscript.Shell
if ($result -eq 'Yes')
    {
        $wshell.Popup("        Beginning transfer. Please wait until completed.",0,"Copy2RO")
        $ErrorActionPreference= 'silentlycontinue'
        $RoboResults = PsExec.exe \\petestapp01.petest.com -u petest.com\sharecopysa -p Cc102289! c:\scripts\callrobo.bat
        sleep -Seconds 5      
        $RoboResults = $($RoboResults| out-string).Trim()
        $tempFile = [System.IO.Path]::GetTempFileName()
        Set-Content -value $RoboResults -Path $tempfile -Force 
        $wshell.Popup("        Transfer Successful!",0,"Copy2RO")
        sleep -Seconds 1
        Add-Type -assemblyname Microsoft.visualBasic
        $command = "NOTEPAD.EXE $tempfile"
        $newProc=[Microsoft.VisualBasic.Interaction]::Shell($command,1,$True)
        del $tempFile
        Remove-Variable tempFile,roboresults,command,newproc
    }
else
    {
        $wshell.Popup("        Canceling Transfer",0,"Copy2RO")
    }
exit