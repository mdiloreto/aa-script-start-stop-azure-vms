    Param 
    (    
		[Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] 
        [String]$Time,
		[Parameter(Mandatory=$true)][ValidateSet("daily","workdays","weekend")] 
        [String]$Range
    ) 
	
    # Ensures you do not inherit an AzContext in your runbook
    Disable-AzContextAutosave -Scope Process

    # Connect to Azure with system-assigned managed identity
    $AzureContext = (Connect-AzAccount -Identity).context

    # set and store context
    $AzureContext = Set-AzContext -SubscriptionName $AzureContext.Subscription -DefaultProfile $AzureContext 
    #Write-Output "Suscripcion " + $AzureContext.Subscription
	#$VmsList = Find-AzResource | where {$_.ResourceType -like "Microsoft.Compute/virtualMachines" `
	#-and $_.Tags.Count -gt 0 -and ($_.Tags.containsKey('poweron') -or $_.Tags.containsKey('poweroff'))}

	$VmsList = Get-AzResource | where {$_.ResourceType -like "Microsoft.Compute/virtualMachines" -and $_.Tags.Count -gt 0}
    #Write-Output "-------- Listado VMs con TAGS $VmsList"
	foreach ($VM in $VmsList)  
	{
		$vmName = $VM.Name
		#$vmRG = $VM.ResourceGroupName
		#$VMDetail = Get-AzVM -ResourceGroupName $vmRG -Name $vmName -Status | Select-Object -ExpandProperty StatusesText | convertfrom-json
		#$vmPowerstate = $VMDetail[1].Code
        
        $poweron = ($VM).Tags["poweron"]
        $poweroff = ($VM).Tags["poweroff"]
        $poweron2 = ($VM).Tags["poweron2"]
        $poweroff2 = ($VM).Tags["poweroff2"]
        <#     
        $poweron = (($VM).Tags | Where-Object { $_.Name -eq 'poweron'}).Value
        $poweroff = (($VM).Tags | Where-Object { $_.Name -eq 'poweroff'}).Value

        $poweron2 = (($VM).Tags | Where-Object { $_.Name -eq 'poweron2'}).Value
        $poweroff2 = (($VM).Tags | Where-Object { $_.Name -eq 'poweroff2'}).Value
        #>

		#Write-Output "VM name $vmName"
		#Write-Output "Poweron $poweron"
		#Write-Output "Poweroff $poweroff"
        #Write-Output "Poweron2 $poweron2"
		#Write-Output "Poweroff2 $poweroff2"

        if($poweron -ne $null) {
			$timeRangeList = @($poweron -split "-" | foreach {$_.Trim()})
            #Write-Output "Time Range List para poweron de la VM $vmName - $timeRangeList"
			if(($timeRangeList[0] -ieq $Range) -and ($timeRangeList[1] -ieq $Time)) {
                Write-Output "Se comienza a encender la VM $vmName"
                $VM | Start-AzVM
            }
		}
        		
		if($poweroff -ne $null) {
			$timeRangeList = @($poweroff -split "-" | foreach {$_.Trim()})
             #Write-Output "Time Range List para poweroff de la VM $vmName - $timeRangeList"
			if(($timeRangeList[0] -ieq $Range) -and ($timeRangeList[1] -ieq $Time)) {
                Write-Output "Se comienza a apagar la VM $vmName"
                $VM | Stop-AzVM -Force  
            }
		}	

        if($poweron2 -ne $null) {
			$timeRangeList = @($poweron2 -split "-" | foreach {$_.Trim()})
             #Write-Output "Time Range List para poweron2 de la VM $vmName - $timeRangeList"
			if(($timeRangeList[0] -ieq $Range) -and ($timeRangeList[1] -ieq $Time)) {
                Write-Output "Se comienza a encender la VM $vmName"
                $VM | Start-AzVM
            }
		}
        		
		if($poweroff2 -ne $null) {
			$timeRangeList = @($poweroff2 -split "-" | foreach {$_.Trim()})
             #Write-Output "Time Range List para poweroff2 de la VM $vmName - $timeRangeList"
			if(($timeRangeList[0] -ieq $Range) -and ($timeRangeList[1] -ieq $Time)) {
                Write-Output "Se comienza a apagar la VM $vmName"
                $VM | Stop-AzVM -Force  
            }
		}	
	}
