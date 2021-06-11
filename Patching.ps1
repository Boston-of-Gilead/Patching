#PowerCLI/Remote windows patching

Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false
Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP $false

Write-host "For this script to work you need to be in an admin PS session, logged in with an admin account, and have PowerCLI and PSWindowsUpdate installed."

$Admin = Read-host -Prompt "Enter your admin username, which should be your logged in user"
$Date = Get-Date -Format "MM/dd/yyyy"
$Init = $Admin.Substring(0,2).ToUpper()
$Name = $Init + " - " + $Date

Connect-VIServer -Server vmwareserver

#Make list of servers
$List = Get-Content -path "c:\path_to\patchlist.txt"

#Take snapshots. You will need PowerCLI.
forEach ($i in $List){
    New-Snapshot -VM $i -Name $Name -Description "Snap before patching" -Quiesce #-Memory
    }

Write-host "Snaps completed"

#Snapshot portion works.

#Install updates. You will need PSWindowsUpdate installed.
forEach ($i in $List){
    #Update listgen and cleanup - GOOD
    $file1 = 'C:\path_to\availableupdates.txt'
    $action = Get-Wulist | Format-List -property KB | out-file -filepath $file1
    $action

    $content = Get-Content -Path 'C:\path_to\availableupdates.txt'
    $newContent = $content -replace 'KB : ',""
    $newContent | Set-Content -Path 'C:\path_to\availableupdates.txt'

    @(gc C:\path_to\availableupdates.txt) -match '\S'  | out-file C:\path_to\availableupdates.txt

    #Update run
    forEach ($j in $content){
        Get-WindowsUpdate -KBArticleID $j -Install 
        Write-host $j
    }

    Remove-Item -Path 'C:\path_to\availableupdates.txt' -Force
}
