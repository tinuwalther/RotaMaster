# RotaMaster OpsGenie Integration

#region functions
function Get-OpsGenieRotation {
    <#
    .SYNOPSIS
        A short one-line action-based description, e.g. 'Tests if a function is valid'
    .DESCRIPTION
        A longer description of the function, its purpose, common use cases, etc.
    .NOTES
        Information or caveats about the function e.g. 'This function is not supported in Linux'
    .EXAMPLE
        New-MwaFunction @{Name='MyName';Value='MyValue'} -Verbose
        Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
    #>
    [CmdletBinding(SupportsShouldProcess=$True)]
    param(
        # Name of the schedule
        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            Position = 0
        )]
        [String] $Schedule,

        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            Position = 1
        )]
        [String] $ApiKey
    )

    begin{
        #region Do not change this region
        $StartTime = Get-Date
        $function = $($MyInvocation.MyCommand.Name)
        Write-Verbose $('[', (Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'), ']', '[ Begin   ]', $function -Join ' ')
        #endregion
    }

    process{
        Write-Verbose $('[', (Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'), ']', '[ Process ]', $function -Join ' ')
        foreach($item in $PSBoundParameters.keys){ $params = "$($params) -$($item) $($PSBoundParameters[$item])" }
        if ($PSCmdlet.ShouldProcess($params.Trim())){
            try{
                # Define variables
                $BaseUrl = "https://api.eu.opsgenie.com/v2/schedules/$Schedule/rotations?scheduleIdentifierType=name"

                # Create headers for the API request
                $Headers = @{
                    Authorization = "GenieKey $ApiKey"
                }

                # Send the GET request to OpsGenie API
                try {
                    $Response = Invoke-RestMethod -Uri $BaseUrl -Headers $Headers -Method Get
                    if($Response){
                        $Response.data
                    }else{
                        $Response
                    }
                }
                catch {
                    Write-Warning "Failed to retrieve ."
                    Write-Warning $_.Exception.Message
                }
            }catch{
                Write-Warning $('ScriptName:', $($_.InvocationInfo.ScriptName), 'LineNumber:', $($_.InvocationInfo.ScriptLineNumber), 'Message:', $($_.Exception.Message) -Join ' ')
                $Error.Clear()
            }
        }
    }

    end{
        #region Do not change this region
        Write-Verbose $('[', (Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'), ']', '[ End     ]', $function -Join ' ')
        $TimeSpan  = New-TimeSpan -Start $StartTime -End (Get-Date)
        $Formatted = $TimeSpan | ForEach-Object {
            '{1:0}h {2:0}m {3:0}s {4:000}ms' -f $_.Days, $_.Hours, $_.Minutes, $_.Seconds, $_.Milliseconds
        }
        Write-Verbose $('Finished in:', $Formatted -Join ' ')
        #endregion
    }
}

function New-OpsGenieRotation {
    <#
    .SYNOPSIS
        A short one-line action-based description, e.g. 'Tests if a function is valid'
    .DESCRIPTION
        A longer description of the function, its purpose, common use cases, etc.
    .NOTES
        Information or caveats about the function e.g. 'This function is not supported in Linux'
    .EXAMPLE
        New-MwaFunction @{Name='MyName';Value='MyValue'} -Verbose
        Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
    #>
    [CmdletBinding(SupportsShouldProcess=$True)]
    param(
        # Name of the schedule
        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            Position = 0
        )]
        [String] $Schedule,

        # Name of the Rotation
        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            Position = 1
        )]
        [String] $Rotation,

        # Start date as 2024-12-24 10:00
        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            Position = 2
        )]
        [String] $startDate,

        # End date as 2024-12-31 10:00
        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            Position = 3
        )]
        [String] $endDate,

        # Participants as Array of PSCustomObject
        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            Position = 4
        )]
        [Object] $participants,

        # API Key
        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            Position = 5
        )]
        [String] $ApiKey
    )

    begin{
        #region Do not change this region
        $StartTime = Get-Date
        $function = $($MyInvocation.MyCommand.Name)
        Write-Verbose $('[', (Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'), ']', '[ Begin   ]', $function -Join ' ')
        #endregion
    }

    process{
        Write-Verbose $('[', (Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'), ']', '[ Process ]', $function -Join ' ')
        foreach($item in $PSBoundParameters.keys){ $params = "$($params) -$($item) $($PSBoundParameters[$item])" }
        if ($PSCmdlet.ShouldProcess($params.Trim())){
            try{
                # Define variables
                $BaseUrl = "https://api.eu.opsgenie.com/v2/schedules/$Schedule/rotations?scheduleIdentifierType=name"

                # Create headers for the API request
                $Headers = @{
                    Authorization = "GenieKey $ApiKey"
                    "Content-Type" = "application/json"
                }

                # Create the body the API request
                $Payload = [PSCustomObject]@{
                    name         = $Rotation
                    startDate    = (Get-Date $startDate).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
                    endDate      = (Get-Date $endDate).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
                    type         = 'weekly'
                    participants = $participants
                }
                $JsonPayload = $Payload | ConvertTo-Json -Depth 10 -Compress
                Write-Verbose $($Payload | Out-String) -Verbose

                try {
                    Invoke-RestMethod -Uri $BaseUrl -Headers $Headers -Method POST -Body $JsonPayload
                }
                catch {
                    Write-Warning $_.Exception.Message
                }
            }catch{
                Write-Warning $('ScriptName:', $($_.InvocationInfo.ScriptName), 'LineNumber:', $($_.InvocationInfo.ScriptLineNumber), 'Message:', $($_.Exception.Message) -Join ' ')
                $Error.Clear()
            }
        }
    }

    end{
        #region Do not change this region
        Write-Verbose $('[', (Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'), ']', '[ End     ]', $function -Join ' ')
        $TimeSpan  = New-TimeSpan -Start $StartTime -End (Get-Date)
        $Formatted = $TimeSpan | ForEach-Object {
            '{1:0}h {2:0}m {3:0}s {4:000}ms' -f $_.Days, $_.Hours, $_.Minutes, $_.Seconds, $_.Milliseconds
        }
        Write-Verbose $('Finished in:', $Formatted -Join ' ')
        #endregion
    }
}

function Get-OpsGenieOverride {
    <#
    .SYNOPSIS
        A short one-line action-based description, e.g. 'Tests if a function is valid'
    .DESCRIPTION
        A longer description of the function, its purpose, common use cases, etc.
    .NOTES
        Information or caveats about the function e.g. 'This function is not supported in Linux'
    .EXAMPLE
        New-MwaFunction @{Name='MyName';Value='MyValue'} -Verbose
        Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
    #>
    [CmdletBinding(SupportsShouldProcess=$True)]
    param(
        # Name of the schedule
        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            Position = 0
        )]
        [String] $Schedule,

        # API Key
        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            Position = 1
        )]
        [String] $ApiKey
    )

    begin{
        #region Do not change this region
        $StartTime = Get-Date
        $function = $($MyInvocation.MyCommand.Name)
        Write-Verbose $('[', (Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'), ']', '[ Begin   ]', $function -Join ' ')
        #endregion
    }

    process{
        Write-Verbose $('[', (Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'), ']', '[ Process ]', $function -Join ' ')
        foreach($item in $PSBoundParameters.keys){ $params = "$($params) -$($item) $($PSBoundParameters[$item])" }
        if ($PSCmdlet.ShouldProcess($params.Trim())){
            try{
                # Define variables
                $BaseUrl = "https://api.eu.opsgenie.com/v2/schedules/$Schedule/overrides?scheduleIdentifierType=name"

                # Create headers for the API request
                $Headers = @{
                    Authorization = "GenieKey $ApiKey"
                    "Content-Type" = "application/json"
                }

                try {
                    $Response = Invoke-RestMethod -Uri $BaseUrl -Headers $Headers -Method Get
                    if($Response){
                        $Response.data
                    }else{
                        $Response
                    }
                }
                catch {
                    Write-Warning $_.Exception.Message
                }
            }catch{
                Write-Warning $('ScriptName:', $($_.InvocationInfo.ScriptName), 'LineNumber:', $($_.InvocationInfo.ScriptLineNumber), 'Message:', $($_.Exception.Message) -Join ' ')
                $Error.Clear()
            }
        }
    }

    end{
        #region Do not change this region
        Write-Verbose $('[', (Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'), ']', '[ End     ]', $function -Join ' ')
        $TimeSpan  = New-TimeSpan -Start $StartTime -End (Get-Date)
        $Formatted = $TimeSpan | ForEach-Object {
            '{1:0}h {2:0}m {3:0}s {4:000}ms' -f $_.Days, $_.Hours, $_.Minutes, $_.Seconds, $_.Milliseconds
        }
        Write-Verbose $('Finished in:', $Formatted -Join ' ')
        #endregion
    }
}

function New-OpsGenieOverride {
    <#
    .SYNOPSIS
        A short one-line action-based description, e.g. 'Tests if a function is valid'
    .DESCRIPTION
        A longer description of the function, its purpose, common use cases, etc.
    .NOTES
        Information or caveats about the function e.g. 'This function is not supported in Linux'
    .EXAMPLE
        New-MwaFunction @{Name='MyName';Value='MyValue'} -Verbose
        Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
    #>
    [CmdletBinding(SupportsShouldProcess=$True)]
    param(
        # Name of the schedule
        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            Position = 0
        )]
        [String] $Schedule,

        # Name of the Rotation
        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            Position = 1
        )]
        [Object] $Rotation,

        # Start date as 2024-12-24 10:00
        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            Position = 2
        )]
        [String] $startDate,

        # End date as 2024-12-31 10:00
        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            Position = 3
        )]
        [String] $endDate,

        # Participants as Array of PSCustomObject
        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            Position = 4
        )]
        [Object] $participants,

        # API Key
        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            Position = 5
        )]
        [String] $ApiKey
    )

    begin{
        #region Do not change this region
        $StartTime = Get-Date
        $function = $($MyInvocation.MyCommand.Name)
        Write-Verbose $('[', (Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'), ']', '[ Begin   ]', $function -Join ' ')
        #endregion
    }

    process{
        Write-Verbose $('[', (Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'), ']', '[ Process ]', $function -Join ' ')
        foreach($item in $PSBoundParameters.keys){ $params = "$($params) -$($item) $($PSBoundParameters[$item])" }
        if ($PSCmdlet.ShouldProcess($params.Trim())){
            try{
                # Define variables
                $BaseUrl = "https://api.eu.opsgenie.com/v2/schedules/$Schedule/overrides?scheduleIdentifierType=name"

                # Create headers for the API request
                $Headers = @{
                    Authorization = "GenieKey $ApiKey"
                    "Content-Type" = "application/json"
                }

                # Create the body the API request
                $Payload = [PSCustomObject]@{
                    #alias        = ([guid]::NewGuid()).Guid
                    user         = $participants[0]
                    startDate    = (Get-Date $startDate).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
                    endDate      = (Get-Date $endDate).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
                    rotations    = $Rotation
                }
                $JsonPayload = $Payload | ConvertTo-Json -Depth 10 -Compress

                try {
                    Invoke-RestMethod -Uri $BaseUrl -Headers $Headers -Method POST -Body $JsonPayload
                }
                catch {
                    Write-Warning $_.Exception.Message
                }
            }catch{
                Write-Warning $('ScriptName:', $($_.InvocationInfo.ScriptName), 'LineNumber:', $($_.InvocationInfo.ScriptLineNumber), 'Message:', $($_.Exception.Message) -Join ' ')
                $Error.Clear()
            }
        }
    }

    end{
        #region Do not change this region
        Write-Verbose $('[', (Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'), ']', '[ End     ]', $function -Join ' ')
        $TimeSpan  = New-TimeSpan -Start $StartTime -End (Get-Date)
        $Formatted = $TimeSpan | ForEach-Object {
            '{1:0}h {2:0}m {3:0}s {4:000}ms' -f $_.Days, $_.Hours, $_.Minutes, $_.Seconds, $_.Milliseconds
        }
        Write-Verbose $('Finished in:', $Formatted -Join ' ')
        #endregion
    }
}

function Remove-OpsGenieOverride {
    <#
    .SYNOPSIS
        A short one-line action-based description, e.g. 'Tests if a function is valid'
    .DESCRIPTION
        A longer description of the function, its purpose, common use cases, etc.
    .NOTES
        Information or caveats about the function e.g. 'This function is not supported in Linux'
    .EXAMPLE
        New-MwaFunction @{Name='MyName';Value='MyValue'} -Verbose
        Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
    #>
    [CmdletBinding(SupportsShouldProcess=$True)]
    param(
        # Name of the schedule
        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            Position = 0
        )]
        [String] $Schedule,

        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            Position = 1
        )]
        [String] $Alias,

        # API Key
        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            Position = 2
        )]
        [String] $ApiKey
    )

    begin{
        #region Do not change this region
        $StartTime = Get-Date
        $function = $($MyInvocation.MyCommand.Name)
        Write-Verbose $('[', (Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'), ']', '[ Begin   ]', $function -Join ' ')
        #endregion
    }

    process{
        Write-Verbose $('[', (Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'), ']', '[ Process ]', $function -Join ' ')
        foreach($item in $PSBoundParameters.keys){ $params = "$($params) -$($item) $($PSBoundParameters[$item])" }
        if ($PSCmdlet.ShouldProcess($params.Trim())){
            try{
                # Define variables
                $BaseUrl = "https://api.eu.opsgenie.com/v2/schedules/$ScheduleName/overrides/$($Alias)?scheduleIdentifierType=name"

                # Create headers for the API request
                $Headers = @{
                    Authorization = "GenieKey $ApiKey"
                }

                try {
                    Invoke-RestMethod -Uri $BaseUrl -Headers $Headers -Method DELETE
                }
                catch {
                    Write-Warning $_.Exception.Message
                }
            }catch{
                Write-Warning $('ScriptName:', $($_.InvocationInfo.ScriptName), 'LineNumber:', $($_.InvocationInfo.ScriptLineNumber), 'Message:', $($_.Exception.Message) -Join ' ')
                $Error.Clear()
            }
        }
    }

    end{
        #region Do not change this region
        Write-Verbose $('[', (Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'), ']', '[ End     ]', $function -Join ' ')
        $TimeSpan  = New-TimeSpan -Start $StartTime -End (Get-Date)
        $Formatted = $TimeSpan | ForEach-Object {
            '{1:0}h {2:0}m {3:0}s {4:000}ms' -f $_.Days, $_.Hours, $_.Minutes, $_.Seconds, $_.Milliseconds
        }
        Write-Verbose $('Finished in:', $Formatted -Join ' ')
        #endregion
    }
}
#endregion

################################################################################################
# How does a Rotation looks like in OpsGenie?
# - Create a Rotation for one year
# - Initial Rotation contains none
#
# RotaMaster
# Button Eintragen: 
# - if('Pikett'){API Call to OpsGenie with Override}
# - Remove single event 'Pikett' deletes also the Override in OpsGenie
# - Move single event 'Pikett' deletes also the Override and create a new Override in OpsGenie
#
################################################################################################

# Year Rotation
$ScheduleName       = 'Test_schedule'
$ScheduleApiKey     = 'Salted SHA256 ApiKey'

$RotationNameYear   = 'OnCall 2025'
$RotationStartYear  = '2025-01-01 10:00'
$RotationEndYear    = '2025-12-31 10:00'

$AllOpsGenieRotations = Get-OpsGenieRotation -Schedule $ScheduleName -ApiKey $ScheduleApiKey

# Initial OpsGenie Rotation
if($AllOpsGenieRotations.name -contains $RotationNameYear){
    Write-Warning "$RotationNameYear already exists!"
}else {
    $participants = @(
        [PSCustomObject]@{
            type = "none"
        }
    )
    $InitialOpsGenieRotation = New-OpsGenieRotation -Schedule $ScheduleName -Rotation $RotationNameYear -startDate $RotationStartYear -endDate $RotationEndYear -participants $participants -ApiKey $ScheduleApiKey -Verbose
    $InitialOpsGenieRotation
}

# Write next Override -> Button Eintragen/Move event
$RotationStart  = '2025-01-06 10:00'
$RotationEnd    = (Get-Date $RotationStart).AddDays(7) #'2025-01-13 10:00'
$participants = @(
    [PSCustomObject]@{
        type = 'user'
        username = 'tim.stampfli@inventx.ch'
    }
)

$rotations = @(
    [PSCustomObject]@{
        name = $RotationNameYear
    }
)

$NewOpsGenieOverride = New-OpsGenieOverride -Schedule $ScheduleName -Rotation $rotations -startDate $RotationStart -endDate $RotationEnd -participants $participants -ApiKey $ScheduleApiKey -Verbose
$NewOpsGenieOverride

# Delete Override -> Remove event/Move event
$AllOpsGenieOverrides = Get-OpsGenieOverride -Schedule $ScheduleName -ApiKey $ScheduleApiKey
$Alias = $AllOpsGenieOverrides.Where({$_.user -match 'tim.stampfli'}) | Select-Object -ExpandProperty alias
# How to find the correct alias for the Override?
if($Alias){
    Remove-OpsGenieOverride -Schedule $ScheduleName -Alias $Alias -ApiKey $ScheduleApiKey
}else {
    Write-Host "No Override found for user"
}
