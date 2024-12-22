# ix.RotaMaster OpsGenie Integration

#region functions
function Get-OpsGenieSchedule {
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
        # Test-Compute_schedule
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
                # $BaseUrl = "https://api.eu.opsgenie.com/v2/schedules/$Schedule?identifierType=name"
                $BaseUrl = "https://api.eu.opsgenie.com/v2/schedules"

                # Create headers for the API request
                $Headers = @{
                    Authorization = "GenieKey $ApiKey"
                }

                # Construct the URL for the specific rotation
                #$Url = "$BaseUrl/$RotationId"

                # Send the GET request to OpsGenie API
                try {
                    $Response = Invoke-RestMethod -Uri $BaseUrl -Headers $Headers -Method Get
                    #$Response | ConvertTo-Json -Depth 10 | Write-Output
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
        # Test-Compute_schedule
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

                # Construct the URL for the specific rotation
                #$Url = "$BaseUrl/$RotationId"

                # Send the GET request to OpsGenie API
                try {
                    $Response = Invoke-RestMethod -Uri $BaseUrl -Headers $Headers -Method Get
                    #$Response | ConvertTo-Json -Depth 10 | Write-Output
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
        # Test-Compute_schedule
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
        [String] $Rotation,

        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            Position = 2
        )]
        [String] $startDate,

        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            Position = 3
        )]
        [String] $endDate,

        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            Position = 4
        )]
        [Object] $participants,

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
        # Test-Compute_schedule
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
        [String] $ApiKey,

        [Parameter(
            Mandatory=$false,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            Position = 2
        )]
        [String] $Alias
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
                if([String]::IsNullOrEmpty($Alias)){
                    $BaseUrl = "https://api.eu.opsgenie.com/v2/schedules/$Schedule/overrides?scheduleIdentifierType=name"
                }else{
                    # $ScheduleId = Get-IXOpsGenieSchedule -Schedule $Schedule -ApiKey $ApiKey | Select-Object -ExpandProperty Id
                    # $BaseUrl = "https://api.eu.opsgenie.com/v2/schedules/$($ScheduleId)/overrides/$($Alias)"
                    $BaseUrl = "https://api.eu.opsgenie.com/v2/schedules/$($Schedule)/overrides/$($Alias)"
                }

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
        # Test-Compute_schedule
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
        [Object] $Rotation,

        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            Position = 2
        )]
        [String] $startDate,

        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            Position = 3
        )]
        [String] $endDate,

        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            Position = 4
        )]
        [Object] $participants,

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
        # Test-Compute_schedule
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

#region Year/Initial Rotation
$ScheduleName       = 'Test_schedule'
$ScheduleApiKey     = 'ApiKey'
$Schedule           = Get-OpsGenieSchedule -Schedule $ScheduleName -ApiKey $ScheduleApiKey -Verbose
$Schedule | Format-Table id,name,enabled,rotations

$RotationNameYear   = 'OnCall 2025'
$RotationStartYear  = '2025-01-01 10:00'
$RotationEndYear    = '2025-12-31 10:00'

$AllOpsGenieRotations  = Get-OpsGenieRotation -Schedule $ScheduleName -ApiKey $ScheduleApiKey -Verbose
$AllOpsGenieRotations | Format-Table id,name,startDate,endDate,type,@{N='participants';E={$_.participants.username}}

# Initial OpsGenie Rotation
if($AllOpsGenieRotations.name -contains $RotationNameYear){
    Write-Warning "$RotationNameYear already exists!"
    # make an override or add members?
}else {
    $participants = @(
        [PSCustomObject]@{
            type = "none"
        }
    )
    $InitialOpsGenieRotation = New-OpsGenieRotation -Schedule $ScheduleName -Rotation $RotationNameYear -startDate $RotationStartYear -endDate $RotationEndYear -participants $participants -ApiKey $ScheduleApiKey -Verbose
    $InitialOpsGenieRotation
}
#endregion

#region List all Overrides
$AllOpsGenieOverrides = Get-OpsGenieOverride -Schedule $ScheduleName -ApiKey $ScheduleApiKey
$AllOpsGenieOverrides | Format-Table alias,@{N='username';E={$_.user.username}},startDate,endDate,@{N='rotations';E={$_.rotations.name}}
#endregion

#region Write next Override -> Button Eintragen/Move event
$Username  = 'one.user@company.com'
$participants = @(
    [PSCustomObject]@{
        type = 'user'
        username = $Username
    }
)

$rotations = @(
    [PSCustomObject]@{
        name = $RotationNameYear
    }
)

$OnCallStart = '2025-03-17 10:00'
$OnCallEnd   = Get-Date (Get-Date $OnCallStart).AddDays(7) -f 'yyyy-MM-dd HH:mm' #'2025-02-24 12:00'
$NewOpsGenieOverride  = New-OpsGenieOverride -Schedule $ScheduleName -Rotation $rotations -startDate $OnCallStart -endDate $OnCallEnd -participants $participants -ApiKey $ScheduleApiKey -Verbose
$LastOpsGenieOverride = Get-OpsGenieOverride -Schedule $ScheduleName -ApiKey $ScheduleApiKey -Alias $($NewOpsGenieOverride.data.alias) -Verbose
$LastOpsGenieOverride | Format-Table alias,@{N='username';E={$_.user.username}},startDate,endDate,@{N='rotations';E={$_.rotations.name}}
#endregion

#region Delete Override -> Remove event/Move event
$Username  = 'one.user@company.com'
$StartDate = '13.01.2025 10:00:00'

$AllOpsGenieOverrides = Get-OpsGenieOverride -Schedule $ScheduleName -ApiKey $ScheduleApiKey
$UserOverride = $AllOpsGenieOverrides.Where({$_.user.username -match $Username})
$UserOverride | Format-Table @{N='Username';E={$_.user.username}},@{N='Rotation';E={$_.rotations.name}},startDate,endDate

if($UserOverride){
    $alias = $UserOverride.Where({$_.startDate.ToShortDateString() -match (Get-Date $StartDate).ToShortDateString()}) | Select-Object -ExpandProperty alias
    if($alias){
        Remove-OpsGenieOverride -Schedule $ScheduleName -Alias $alias -ApiKey $ScheduleApiKey -Verbose
    }else {
        Write-Host "No Override found for $($Username)"
    }
}
#endregion
