@echo off
echo %0 PowerShell -NoProfile -ExecutionPolicy Bypass -Command -
more +6 %0 | PowerShell -NoProfile -ExecutionPolicy Bypass -Command -
exit /b



# Clear-Host
Write-Host -fore green "Starte PowerShell..." 
#--------------------------------------------------------------------
# Add Veeam snap-in if required

If ((Get-PSSnapin -Name VeeamPSSnapin -ErrorAction SilentlyContinue) -eq $null) {
   Add-PSSnapin VeeamPSSnapin
   }
#--------------------------------------------------------------------
# Check presence if VEEAM PowerShell plugin is installed or not

If ((Get-PSSnapin -Name VeeamPSSnapin -ErrorAction SilentlyContinue) -eq $null) {
   [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
   $nl = [System.Environment]::NewLine + [System.Environment]::NewLine
   $msg = ""
   $msg = $msg + "*** Achtung: ***" + $nl
   $msg = $msg + "Das VEEAM PowerShell Snapin ist nicht vorhanden!" + $nl
   $msg = $msg + "Zuerst muß die VEEAM PowerShell installiert werden." + $nl
   $msg = $msg + "Das Script wird nun beendet." + $nl
   [System.Windows.Forms.MessageBox]::Show($msg,"?error. " + $myInvocation.MyCommand.Name,"OK","Error")
   exit
   }
#--------------------------------------------------------------------
# Check Veeam Version (If VEEAM 9)

If ((Get-PSSnapin VeeamPSSnapin).Version.Major -ne 9) {
   New-EventLog –LogName Application –Source "VEEAM Scripts" -ErrorAction:SilentlyContinue
   Write-EventLog -LogName "Application" -Source "VEEAM Scripts" -EventID 3001 -EntryType Warning -Message "ERROR: VEEAM Version 9.x script execution error! Check scripts in c:\scripts..."
   exit
   }

#--------------------------------------------------------------------
# Main Procedures
Write-Host "********************************************************************************"
write-host "Starting Veeam Script" $myInvocation.MyCommand.Name
Write-Host "********************************************************************************`n"
#--------------------------------------------------------------------

write-host "`nTape Sever identifizieren ..."
Get-VBRLocalhost | Get-VBRTapeServer
    
write-host "`nTape Library einlesen ..."
Get-VBRTapeServer | Get-VBRTapeLibrary

write-host "`n...inventarisieren und auf Abschluss warten ..."
Get-VBRTapeLibrary | Start-VBRTapeInventory -wait

write-host "`nAktuelles Tape Drive identifizieren ..."
$drive = Get-VBRTapeDrive

write-host "`n...und Katalog des aktuellen Bandes einlesen und auf Abschluss warten."
Get-VBRTapeMedium -Drive $drive | Start-VBRTapeCatalog -Wait

write-host "`nAktuelles Medium in den Pool 'FREE' schieben ..."
Get-VBRTapeMedium -Drive $drive | Move-VBRTapeMedium -MediaPool "Free" -Confirm:$false

write-host "`n... und loeschen und auf Abschluss warten ..."
Get-VBRTapeMedium -Drive $drive | Erase-VBRTapeMedium -wait -Confirm:$false

exit
