#@echo off
#echo %0 PowerShell -NoProfile -ExecutionPolicy Bypass -Command -
#more +6 %0 | PowerShell -NoProfile -ExecutionPolicy Bypass -Command -
#exit /b

# ##########################################################################################################
# We need this SnapIn for VEEAM first,
# and we must of course stop, if it's missing
# (GUI part with a little help from this site:)
# https://blogs.technet.microsoft.com/stephap/2012/04/23/building-forms-with-powershell-part-1-the-form/
# ##########################################################################################################

If ((Get-PSSnapin -Name VeeamPSSnapin -ErrorAction SilentlyContinue) -eq $null) {Add-PSSnapin VeeamPSSnapin}
If ((Get-PSSnapin -Name VeeamPSSnapin -ErrorAction SilentlyContinue) -eq $null) 

$MessageboxTitle = “Get-PSSnapin -Name VeeamPSSnapin failed error:”
$Messageboxbody = @"
Das Powershell SnapIn "VEEAMPSSSnapin" konnte nicht aktiviert werden.`n`n
Ist die VEEAM Powershell installiert?`n`n
For more info see:`n
http://helpcenter.veeam.com/docs/backup/powershell/`n
https://hyperv.veeam.com/blog/how-to-use-veeam-powershell-snap-in-hyper-v-backup/`n
"@

# load assembly
Add-Type -AssemblyName System.Windows.Forms
$Form = New-Object system.Windows.Forms.Form #create object
$Form.Text = "$MessageboxTitle" #object title
$Form.AutoScroll = $True
$Form.AutoSize = $True
$Form.AutoSizeMode = "GrowAndShrink"
$Form.WindowState = "Normal"
$Form.Opacity = 0.9
$Form.StartPosition = "CenterScreen"
$Font = New-Object System.Drawing.Font("Times New Roman",18,[System.Drawing.FontStyle]::Italic)
    # Font styles are: Regular, Bold, Italic, Underline, Strikeout
$Form.Font = $Font
$Label = New-Object System.Windows.Forms.Label # object text
$Label.Text = "$Messageboxbody"
$Label.AutoSize = $True
$Form.Controls.Add($Label)
$Form.ShowDialog() # output object

# ##########################################################################################################

# Get-VBRLocalhost | Get-VBRServer ### Does not work!
# Get-VBRLocalhost | Get-Member

$vbrservername = Get-VBRLocalhost
# $vbrservername != $env:computername
Write-Host $vbrservername
Write-Host $env:computername

# Thus: Workaround
Get-VBRServer -server $env:computername

#Find-VBRHvEntity -Server WIN-SRV2016Temp
#Find-VBRHvEntity -Server $env:computername
#this is more elegant
Get-VBRLocalhost | Find-VBRHvEntity


if (Get-VBRBackupRepository -Name Tagesrepository) {Get-VBRBackupRepository -Name Tagesrepository}
else {Write-Warning "Tagesrepository fehlt!"}

if (Get-VBRBackupRepository -Name Wochenrepository) {Get-VBRBackupRepository -Name wochenrepository}
else {Write-Warning "Wochenrepository fehlt!"}



Get-VBRBackupRepository -Name Wochenrepository
Get-VBRBackupRepository -Name Tagesrepository
$hvserver = Find-VBRHvEntity -Server $env:computername
$repository = Get-VBRBackupRepository -Name Tagesrepository
Add-VBRHvBackupJob -Name "2 - Tagesrepository" -Entity $hvserver -BackupRepository $repository
$backupjob = Get-VBRJob -Name "1 - Wochenrepository"
Find-VBRHvEntity -Server $env:computername
Find-VBRHvEntity -Name $env:computername
Find-VBRHvEntity -Name "$env:computername" | Add-VBRHvJobObject -Job $backupjob
Find-VBRHvEntity -Server "$env:computername" | Add-VBRHvJobObject -Job $backupjob
Get-VBRJob -Name "1 - Wochenrepository" | fl
Get-VBRJob -Name "2 - Tagesrepository" | Set-VBRJobAdvancedBackupOptions -Algorithm ReverseIncremental -EnableFullBackup:$true -FullBackupScheduleKind Daily -FullBackupDays Friday
