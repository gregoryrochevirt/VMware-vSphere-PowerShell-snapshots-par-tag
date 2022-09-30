Import-Module vmware.powerCLI
# User Variables
$vCenterFQDN = "vcenter01.wtiger.eu"
$vCenterUser = "administrator@vsphere.local"
$vCenterPassword = "VMware1!"
#$VMList = Get-VM -Tag 6-vESXi-Lab_Pod_150
#$SnapshotName = "Start"
###############################
# DO NOT EDIT BELOW THIS LINE #
###############################


# Connect to vCenter
Connect-VIServer $vCenterFQDN -username $vCenterUser -password $vCenterPassword

Function Show-Tag {
    param (
        [string]$Title = 'vCenter Tag'
    )
    Clear-Host
    Write-Host "================ $Title ================"

    $Menu = @{}

    (Get-Tag).Name | Sort-Object | ForEach-Object -Begin {$i = 1} { 

        Write-Host "'$i' $_"
        $Menu.add("$i",$_)
        $i++
    }

    Write-Host "Q: Press 'Q' to quit."

    $Selection = Read-Host "Please make a selection"

    if ($Selection -eq 'Q') { Return } Else { $Menu.$Selection }

    
}

Function Show-Snapshot {
    param (
        [string]$Title1 = 'Snapshot'
    )
    Clear-Host
    Write-Host "================ $Title1 ================"

    $Menu1 = @{}

    Get-Snapshot -VM $VMList | Sort-Object | ForEach-Object -Begin {$i = 1} { 

        Write-Host "'$i' $_"
        $Menu1.add("$i",$_)
        $i++
    }

    Write-Host "Q: Press 'Q' to quit."

    $Selection1 = Read-Host "Please make a selection"

    if ($Selection1 -eq 'Q') { Return } Else { $Menu1.$Selection1 }

    
}



Function CreateVMSnapshot {
    Foreach ($VM in $VMList) {
    Write-Host "Creating Snapshot for $VM"
    New-Snapshot -VM $VM -Memory -quiesce -Name $SnapshotName1 -RunAsync
                             }                           
                                    }
                     
Function RevertLastVMSnapshot {
    Foreach ($VM in $VMList) {
    Write-Host "Reverting Snapshot for $VM"
    $snap = Get-Snapshot -VM $VM | Sort-Object -Property Created -Descending | Select -First 1
    Set-VM -VM $vm -SnapShot $snap -Confirm:$false  -RunAsync | Out-Null
                             }                           
                                    }
 
Function RevertSpecificVMSnapshot {
    Foreach ($VM in $VMList) {
    Write-Host "Reverting Snapshot for $VM"
    #$snap = Get-Snapshot -VM $VM | Sort-Object -Property Created -Descending | Select -First 1
    Set-VM -VM $vm -SnapShot $SnapshotName -Confirm:$false  -RunAsync | Out-Null
                             }                           
                                    }                                   
 
 Function RemoveVMSnapshot {
    Write-Host "Remove Snapshot for $VM"
    foreach ($vm in $VMList) {
    $snapshot= Get-Snapshot -VM $vm -Name $SnapshotName
    remove-snapshot -snapshot $snapshot -RunAsync -confirm:$false
                                }
                                }
Function anyKey 
{
    Write-Host -NoNewline -Object 'Press any key to return to the main menu...' -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
    Menu
}
                                     
Function Menu 
{
    Clear-Host        
    Do
    {
        Clear-Host                                                                       
        Write-Host -Object 'Please choose an option'
        Write-Host     -Object '**********************'
        Write-Host -Object 'Snapshot VM Options' -ForegroundColor Yellow
        Write-Host     -Object '**********************'
        Write-Host -Object '1.  Snapshot VMs '
        Write-Host -Object ''
        Write-Host -Object '2.  Revert to Last Snapshot '
        Write-Host -Object ''
        Write-Host -Object '3.  Revert To Specific Snapshot '
        Write-Host -Object ''
        Write-Host -Object '4.  Remove Snapshot '
        Write-Host -Object ''
        Write-Host -Object '5.  Exit'
        Write-Host -Object $errout
        $Menu = Read-Host -Prompt '(0-5)'
 
        switch ($Menu) 
        {
           1 
            {
		    $UserSelection = Show-Tag -Title 'vCenter Tag'
		    $SnapshotName1 = Read-Host -Prompt "Snapshot Name?"
		    $VMList = Get-VM -Tag $UserSelection | select -ExpandProperty Name
		    CreateVMSnapshot
                anyKey
            }
            2 
            {
                $UserSelection = Show-Tag -Title 'vCenter Tag'
		    $VMList = Get-VM -Tag $UserSelection | select -ExpandProperty Name
		    RevertLastVMSnapshot
                anyKey
            }
            3 
            {
                $UserSelection = Show-Tag -Title 'vCenter Tag'
		    $VMList = Get-VM -Tag $UserSelection | select -ExpandProperty Name
		    $SnapshotName = Show-Snapshot -Title 'Show-Snapshot'
                RevertSpecificVMSnapshot
                anyKey
            }
            4
            {
                $UserSelection = Show-Tag -Title 'vCenter Tag'
		    $VMList = Get-VM -Tag $UserSelection | select -ExpandProperty Name
		    $SnapshotName = Show-Snapshot -Title 'Show-Snapshot'
		    RemoveVMSnapshot
                anyKey
            }
            5 
            {
                # DisConnect to vCenter
                disconnect-viserver -confirm:$false
                Exit
            }   
            default
            {
                $errout = 'Invalid option please try again........Try 0-4 only'
            }
 
        }
    }
 
    until ($Menu -ne '')
}
 
# Launch The Menu
Menu