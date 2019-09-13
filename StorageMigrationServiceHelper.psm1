# Windows Server Storage Migration Service Helper

# Copyright (c) Microsoft Corporation. All rights reserved.

# MIT License

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.


Function GetSmsLogsFolder
{
    [cmdletbinding()]
    param (
        $Path,
        [ref]$SmsLogsFolder
    )
    $suffix = $null
    $folderNamePrefix = "StorageMigrationLog_$targetComputerName"
    
    do
    {
        $p = $Path + "\$folderNamePrefix"
        if ($suffix -ne $null)
        {
            $p += "_$suffix"
            $suffix += 1
        }
        else
        {
            $suffix = 1
        }
    } while (Test-Path $p -erroraction 'silentlycontinue')
    
    $SmsLogsFolder.value = $p
}

Function LogAction($message)
{
    write "==> $message"
}

Function GetSmsEventLogs
{
    [cmdletbinding()]
    param (
        $SmsLogsFolder
    )

    $names = @{}
    $names.Add("Microsoft-Windows-StorageMigrationService/Debug", "$($targetComputerName)_Sms_Debug.log")
    $names.Add("Microsoft-Windows-StorageMigrationService-Proxy/Debug", "$($targetComputerName)_Proxy_Debug.log")

    foreach ($key in $names.Keys)
    {
        $outFile = $names[$key]
        LogAction "Collecting traces for $($key) (outFile=$outFile)"
        
        $outFullFile = "$SmsLogsFolder\$outFile"
        
        if (! $computerNameWasProvided)
        {
            get-winevent -logname $key -oldest -ea SilentlyContinue | foreach-object {$_.Message} > "$outFullFile"
        }
        else
        {
            if ($Credential -eq $null)
            {
                Get-WinEvent -ComputerName $targetComputerName -logname $key -oldest -ea SilentlyContinue | foreach-object {$_.Message} > "$outFullFile"
            }
            else
            {
                Get-WinEvent -ComputerName $targetComputerName -Credential $Credential -logname $key -oldest -ea SilentlyContinue | foreach-object {$_.Message} > "$outFullFile"
            }
        }
    }
}

Function GetSmsEventLogs2
{
    [cmdletbinding()]
    param (
        $SmsLogsFolder
    )

    $names = @{}
    $names.Add("Microsoft-Windows-StorageMigrationService/Admin", "$($targetComputerName)_Sms_Admin.log")
    $names.Add("Microsoft-Windows-StorageMigrationService/Operational", "$($targetComputerName)_Sms_Operational.log")

    $names.Add("Microsoft-Windows-StorageMigrationService-Proxy/Admin", "$($targetComputerName)_Proxy_Admin.log")
    $names.Add("Microsoft-Windows-StorageMigrationService-Proxy/Operational", "$($targetComputerName)_Proxy_Operational.log")

    foreach ($key in $names.Keys)
    {
        $outFile = $names[$key]
        LogAction "Collecting traces for $($key) (outFile=$outFile)"
        
        $outFullFile = "$SmsLogsFolder\$outFile"
        
        if (! $computerNameWasProvided)
        {
            get-winevent -logname $key -oldest -ea SilentlyContinue | foreach-object { #write "$_.TimeCreated $_.Id $_.LevelDisplayName $_.Message"} > "$outFullFile"
                $id=$_.Id;
                $l = (0, (6 - $id.Length) | Measure -Max).Maximum
                $m = "$($_.TimeCreated) {0,$l} $($_.LevelDisplayName) " -f $id
                $m += $_.Message
                $m
            } > "$outFullFile"

        }
        else
        {
            if ($Credential -eq $null)
            {
                Get-WinEvent -ComputerName $targetComputerName -logname $key -oldest -ea SilentlyContinue | foreach-object {#write "$_.TimeCreated $_.Id $_.LevelDisplayName $_.Message"} > "$outFullFile"
                    $id=$_.Id;
                    $l = (0, (6 - $id.Length) | Measure -Max).Maximum
                    $m = "$($_.TimeCreated) {0,$l} $($_.LevelDisplayName) " -f $id
                    $m += $_.Message
                    $m
                } > "$outFullFile"
            }
            else
            {
                Get-WinEvent -ComputerName $targetComputerName -Credential $Credential -logname $key -oldest -ea SilentlyContinue | foreach-object {#write "$_.TimeCreated $_.Id $_.LevelDisplayName $_.Message"} > "$outFullFile"
                    $id=$_.Id;
                    $l = (0, (6 - $id.Length) | Measure -Max).Maximum
                    $m = "$($_.TimeCreated) {0,$l} $($_.LevelDisplayName) " -f $id
                    $m += $_.Message
                    $m
                } > "$outFullFile"
            }
        }
    }
}


Function GetSystemEventLogs
{
    [cmdletbinding()]
    param (
        $SmsLogsFolder
    )

    $outFile = "$($targetComputerName)_System.log"
    $outFullFile = "$SmsLogsFolder\$outFile"
    
    if (! $computerNameWasProvided)
    {
        get-winevent -logname System -oldest -ea SilentlyContinue | foreach-object {
            $id=$_.Id;
            $l = (0, (6 - $id.Length) | Measure -Max).Maximum
            $m = "$($_.TimeCreated) {0,$l} $($_.LevelDisplayName) " -f $id
            $m += $_.Message
            $m
        } > "$outFullFile"
    }
    else
    {
        if ($Credential -eq $null)
        {
            get-winevent -ComputerName $targetComputerName -logname System -oldest -ea SilentlyContinue | foreach-object {
                $id=$_.Id;
                $l = (0, (6 - $id.Length) | Measure -Max).Maximum
                $m = "$($_.TimeCreated) {0,$l} $($_.LevelDisplayName) " -f $id
                $m += $_.Message
                $m
            } > "$outFullFile"
        }
        else
        {
            get-winevent -ComputerName $targetComputerName -Credential $Credential -logname System -oldest -ea SilentlyContinue | foreach-object {
                $id=$_.Id;
                $l = (0, (6 - $id.Length) | Measure -Max).Maximum
                $m = "$($_.TimeCreated) {0,$l} $($_.LevelDisplayName) " -f $id
                $m += $_.Message
                $m
            } > "$outFullFile"
        }
    }
}

Function GetSystemInfo
{
    [cmdletbinding()]
    param (
        $SmsLogsFolder
    )
    if (! $computerNameWasProvided)
    {
        $remoteFeatures = Get-WindowsFeature
    }
    else
    {
        if ($Credential -eq $null)
        {
            $remoteFeatures = Get-WindowsFeature -ComputerName $targetComputerName
        }
        else
        {
            $remoteFeatures = Get-WindowsFeature -ComputerName $targetComputerName -Credential $Credential
        }
    }
    
    $remoteFeatures | ft -AutoSize
    
    if ($computerNameWasProvided)
    {
        # We want to find out whether SMS cmdlets are present on the local computer
        $features = Get-WindowsFeature *SMS*
    }
    else
    {
        $features = $remoteFeatures
    }

    $areSmsCmdletsAvailable = $false
    $isSmsInstalled = $false
    
    foreach ($feature in $features)
    {
        if ($feature.Name -eq "RSAT-SMS")
        {
            $areSmsCmdletsAvailable = $feature.Installed
            break
        }
    }
    
    foreach ($feature in $remoteFeatures)
    {
        if ($feature.Name -eq "SMS")
        {
            $isSmsInstalled = $feature.Installed
            break
        }
    }
    
    Write "areSmsCmdletsAvailable: $areSmsCmdletsAvailable"
    Write "isSmsInstalled: $isSmsInstalled"

    if ($areSmsCmdletsAvailable -and $isSmsInstalled)
    {
        if (! $computerNameWasProvided)
        {
            $smsStates = Get-SmsState
        }
        else
        {
            if ($Credential -eq $null)
            {
                $smsStates = Get-SmsState -OrchestratorComputerName $targetComputerName
            }
            else
            {
                $smsStates = Get-SmsState -OrchestratorComputerName $targetComputerName -Credential $Credential
            }
        }
        
        write $smsStates
write "After ###################"

        foreach ($state in $smsStates)
        {
            $job = $state.Job
            write "+++"
            write "Inventory summary for job: $job"
            
            if (! $computerNameWasProvided)
            {
                $inventorySummary = Get-SmsState -Name $job -InventorySummary
            }
            else
            {
                if ($Credential -eq $null)
                {
                    $inventorySummary = Get-SmsState -OrchestratorComputerName $targetComputerName -Name $job -InventorySummary
                }
                else
                {
                    $inventorySummary = Get-SmsState -OrchestratorComputerName $targetComputerName -Credential $Credential -Name $job -InventorySummary
                }
            }
            
            write $inventorySummary

            foreach ($entry in $inventorySummary)
            {
                $device = $entry.Device
                write "!!!"
                write "Inventory config detail for device: $device"

                if (! $computerNameWasProvided)
                {
                    $detail = Get-SmsState -Name $job -ComputerName $device -InventoryConfigDetail
                }
                else
                {
                    if ($Credential -eq $null)
                    {
                        $detail = Get-SmsState -OrchestratorComputerName $targetComputerName -Name $job -ComputerName $device -InventoryConfigDetail
                    }
                    else
                    {
                        $detail = Get-SmsState -OrchestratorComputerName $targetComputerName -Credential $Credential -Name $job -ComputerName $device -InventoryConfigDetail
                    }
                }

                write $detail

                write "!!!"
                write "Inventory SMB detail for device: $device"

                if (! $computerNameWasProvided)
                {
                    $detail = Get-SmsState -Name $job -ComputerName $device -InventorySMBDetail
                }
                else
                {
                    if ($Credential -eq $null)
                    {
                        $detail = Get-SmsState -OrchestratorComputerName $targetComputerName -Name $job -ComputerName $device -InventorySMBDetail
                    }
                    else
                    {
                        $detail = Get-SmsState -OrchestratorComputerName $targetComputerName -Credential $Credential -Name $job -ComputerName $device -InventorySMBDetail
                    }
                }

                write $detail
            }

            if ($state.LastOperation -ne "Inventory")
            {
                write "+++"
                write "Transfer summary for job: $job"

                if (! $computerNameWasProvided)
                {
                    $transferSummary = Get-SmsState -Name $job -TransferSummary
                }
                else
                {
                    if ($Credential -eq $null)
                    {
                        $transferSummary = Get-SmsState -OrchestratorComputerName $targetComputerName -Name $job -TransferSummary
                    }
                    else
                    {
                        $transferSummary = Get-SmsState -OrchestratorComputerName $targetComputerName -Credential $Credential -Name $job -TransferSummary
                    }
                }
                
                write $transferSummary

                foreach ($entry in $inventorySummary)
                {
                    $device = $entry.Device
                    write "!!!"
                    write "Transfer SMB detail for device: $device"

                    if (! $computerNameWasProvided)
                    {
                        $detail = Get-SmsState -Name $job -ComputerName $device -TransferSMBDetail
                    }
                    else
                    {
                        if ($Credential -eq $null)
                        {
                            $detail = Get-SmsState -OrchestratorComputerName $targetComputerName -Name $job -ComputerName -ComputerName $device $device -TransferSMBDetail
                        }
                        else
                        {
                            $detail = Get-SmsState -OrchestratorComputerName $targetComputerName -Credential $Credential -Name $job -ComputerName $device -ComputerName $device -TransferSMBDetail
                        }
                    }

                    write $detail
                }
                
                write "+++"
                write "Cutover summary for job: $job"

                if (! $computerNameWasProvided)
                {
                    $cutoverSummary = Get-SmsState -Name $job -CutoverSummary
                }
                else
                {
                    if ($Credential -eq $null)
                    {
                        $cutoverSummary = Get-SmsState -OrchestratorComputerName $targetComputerName -Name $job -CutoverSummary
                    }
                    else
                    {
                        $cutoverSummary = Get-SmsState -OrchestratorComputerName $targetComputerName -Credential $Credential -Name $job -CutoverSummary
                    }
                }

                write $cutoverSummary
            }
            write "==="
        }

    }
}

Function Get-SmsLogs
{
    param (
        [string] $ComputerName = "$Env:ComputerName",
        [System.Management.Automation.PSCredential] $Credential = [PSCredential]::Empty,
        [string] $Path = (Get-Item -Path ".\").FullName
    )

    $error.Clear()
    
    if ($ComputerName -eq $null -or $ComputerName -eq "")
    {
        $computerNameWasProvided = $false
        $targetComputerName = "$env:ComputerName"
    }
    else
    {
        $computerNameWasProvided = $true
        $targetComputerName = $ComputerName
    }

    [string]$smsLogsFolder = ""
    
    GetSmsLogsFolder -Path $path -SmsLogsFolder ([ref]$smsLogsFolder)

    LogAction "Creating directory '$smsLogsFolder'"
    $null = New-Item -Path $smsLogsFolder -Type Directory
    
    Start-Transcript -Path "$smsLogsFolder\$($targetComputerName)_Get-SmsLogs.log" -Confirm:0
    
    $date = Get-Date
    write "Get-SmsLogs started on $date"
    
    Write "ComputerName: '$ComputerName'"
    Write "TargetComputerName: '$targetComputerName'"
    Write "Path: '$Path'"

    GetSmsEventLogs  -SmsLogsFolder $SmsLogsFolder
    GetSmsEventLogs2 -SmsLogsFolder $SmsLogsFolder
    GetSystemEventLogs -SmsLogsFolder $SmsLogsFolder
    GetSystemInfo -SmsLogsFolder $SmsLogsFolder
    
    $date = Get-Date
    write "Get-SmsLogs finished on $date"
    
    Stop-Transcript

    Compress-Archive -Path $SmsLogsFolder -DestinationPath $SmsLogsFolder -CompressionLevel Optimal
    
    LogAction "ZIP file containing the logs: '$($SmsLogsFolder).zip'"
}

Export-ModuleMember -Function Get-SmsLogs
