<# 
.SYNOPSIS 
    A powershell workflow to start Virtual Machines in parallel. 
.DESCRIPTION 
    The runbook will send the start command to a set of Virtual Machines in parallel. The runbook uses two tags
    to identify the Tier of the VM and the start schedule.
    The tags keys and values can be chosen as per your needs.
    Additional tiers can be added by replicating the ForEach block in the script.
    The Tier tags will be used to identify the tiers that should be shutdown in sequence, the lowest number (First Tier) is
    assumed to be the tier to be started first (e.g. Database Tier), the highest number tier will be started last (e.g. Web tier).
    The runbook must be created as a Powershell Workflow in Azure Automation.     
    The runbook schedule should be set to execute the runbook depending on the daily start requirement of the VMs.
    For instance, if VMs tagged as Daily should be turned on a 7am Mon-Fri, the runbook should execute sometime before 7am
    Mon-Fri to allow time for the VMs to start.
    The runbook will start all VMs within a subscription. It can be easily edited to apply to a specific resource group.
    The runbook is intended to be used in conjunction with the //TODO// to power down VMs on a schedule.

.EXAMPLE 
    Runbook scheduled for 6:30AM Monday to Friday.

    ForEach -Parallel ($VM in $VMs) {
        if(($VM.Tags.Keys -eq $($ScheduleTagKey)) -and ($vm.Tags.Values -eq $ScheduleTagValue)){
            if(($vm.Tags.Keys -eq $(TierTagKey)) -and ($vm.Tags.Values -eq $($FirstTier))){
                Write-Output "Starting First Tier VMs"
                Write-Output "Starting: $($VM.Name)"
                Start-AzureRMVM -DefaultProfile $account -Name $VM.Name -ResourceGroupName $VM.ResourceGroupName
            }
        }
    }

    ForEach -Parallel ($VM in $VMs) {
        if(($VM.Tags.Keys -eq $($ScheduleTagKey)) -and ($vm.Tags.Values -eq $ScheduleTagValue)){
            if(($vm.Tags.Keys -eq $(TierTagKey))) -and ($vm.Tags.Values -eq $($SecondTier))){
                Write-Output "Starting Second Tier VMs"
                Write-Output "Starting: $($VM.Name)"
                Start-AzureRMVM -DefaultProfile $account -Name $VM.Name -ResourceGroupName $VM.ResourceGroupName
            }
        }
    }

    ForEach -Parallel ($VM in $VMs) {
        if(($VM.Tags.Keys -eq $($ScheduleTagKey)) -and ($vm.Tags.Values -eq $ScheduleTagValue)){
            if(($vm.Tags.Keys -eq $(TierTagKey))) -and ($vm.Tags.Values -eq $($ThirdTier))){
                Write-Output "Starting Thurd Tier VMs"
                Write-Output "Starting: $($VM.Name)"
                Start-AzureRMVM -DefaultProfile $account -Name $VM.Name -ResourceGroupName $VM.ResourceGroupName
            }
        }
    }
#> 

    
workflow Startup-ARM-VMs-Parallel-Runbook-v2
{
    Param( 
        #Schedule Tag Key
        [Parameter(Mandatory = $true)]
        [String]$ScheduleTagKey,
    
        #Schedule Tag Value
        [Parameter(Mandatory = $true)]
        [String]$ScheduleTagValue,
    
        #Tier Tag Key
        [Parameter(Mandatory = $true)]
        [String]$TierTagKey,
    
        #The Tier Tag Value that identifies the group of VMs that should be powered down first
        [Parameter(Mandatory = $true)]
        [String]$FirstTier,
    
        #The Tier Tag Value that identifies the group of VMs that should be powered down second
        [Parameter(Mandatory = $true)]
        [String]$SecondTier,
    
        #The Tier Tag Value that identifies the group of VMs that should be powered down third
        [Parameter(Mandatory = $true)]
        [String]$ThirdTier) 

    sequence{

        try {
            $Conn = Get-AutomationConnection -Name AzureRunAsConnection
            $account = Connect-AzureRmAccount -ServicePrincipal -Tenant $Conn.TenantID -ApplicationId $Conn.ApplicationID -CertificateThumbprint $Conn.CertificateThumbprint
        }
        catch {
            if(!$account){
                $ErrorMessage = "Account not found."
                throw $ErrorMessage
            }
        }

        $VMs = Get-AzureRMVm
    
        ForEach -Parallel ($VM in $VMs) {
            if(($VM.Tags.Keys -eq $($ScheduleTagKey)) -and ($vm.Tags.Values -eq $($ScheduleTagValue))){
                if(($vm.Tags.Keys -eq $TierTagKey) -and ($vm.Tags.Values -eq $($FirstTier))){
                    Write-Output "Starting First Tier VMs"
                    Write-Output "Starting: $($VM.Name)"
                    Start-AzureRMVM -DefaultProfile $account -Name $VM.Name -ResourceGroupName $VM.ResourceGroupName
                }
            }
        }

        ForEach -Parallel ($VM in $VMs) {
            if(($VM.Tags.Keys -eq $($ScheduleTagKey)) -and ($vm.Tags.Values -eq $($ScheduleTagValue))){
                if(($vm.Tags.Keys -eq $TierTagKey) -and ($vm.Tags.Values -eq $($SecondTier))){
                    Write-Output "Starting Second Tier VMs"
                    Write-Output "Starting: $($VM.Name)"
                    Start-AzureRMVM -DefaultProfile $account -Name $VM.Name -ResourceGroupName $VM.ResourceGroupName
                }
            }
        }

        ForEach -Parallel ($VM in $VMs) {
            if(($VM.Tags.Keys -eq $($ScheduleTagKey)) -and ($vm.Tags.Values -eq $ScheduleTagValue)){
                if(($vm.Tags.Keys -eq $TierTagKey) -and ($vm.Tags.Values -eq $($ThirdTier))){
                    Write-Output "Starting Thurd Tier VMs"
                    Write-Output "Starting: $($VM.Name)"
                    Start-AzureRMVM -DefaultProfile $account -Name $VM.Name -ResourceGroupName $VM.ResourceGroupName
                }
            }
        }

    }
}
