<#
    .SYNOPSIS
    Import On-Call Rotation from CSV to OpsGenie and SQLiteDB

    .DESCRIPTION
    This script imports on-call rotation data from a CSV file into OpsGenie and SQLiteDB.

    .PARAMETER FilePath
    The path to the CSV file containing the on-call rotation data.

    .PARAMETER ScheduleName
    The name of the OpsGenie schedule to which the rotation data will be imported.

    .PARAMETER RotationName
    The name of the OpsGenie rotation to which the on-call data will be imported.

    .PARAMETER prod
    A switch parameter to indicate if the import is for the production environment.

    .EXAMPLE
    Import-OnCallRotationFromCSV.ps1 -FilePath '.\on-call-rota-2025-dev.csv' -ScheduleName 'Test-Schedule_schedule' -RotationName '2025'
    This example imports the on-call rotation data from the specified CSV file into the development environment.

    .EXAMPLE
    Import-OnCallRotationFromCSV.ps1 -FilePath '.\on-call-rota-2025.csv' -ScheduleName 'Schedule_schedule' -RotationName '2025' -prod
    This example imports the on-call rotation data from the specified CSV file into the production environment.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$FilePath,

    [Parameter(Mandatory = $true)]
    [String]$ScheduleName, 

    [Parameter(Mandatory = $true)]
    [String]$RotationName,

    [Parameter(Mandatory = $false)]
    [Switch]$prod
)

begin{
    #region Do not change this region
    $StartTime = Get-Date
    $function = $($MyInvocation.MyCommand.Name)
    Write-Verbose $('[', (Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'), ']', '[ Begin   ]', $function -Join ' ')
    #endregion

    #region Get Email
    function Get-EmailFromPerson {
        param (
            [Parameter(Mandatory=$true)]
            [string]$dbPath,

            [Parameter(Mandatory=$true)]
            [string]$person
        )
    
        # Assumption: Order is fixed, but can be made adjustable.
        $user = $person -split '\s'
        Write-Verbose $($user | Out-String)
        $sql = "SELECT name,firstname,email FROM person WHERE name LIKE '%$($user[0])%' AND firstname LIKE '%$($user[1])%'"
    
        $connection = New-SQLiteConnection -DataSource $dbPath
        $data = Invoke-SqliteQuery -Connection $connection -Query $sql
        $data | ForEach-Object{
            $_.email
        }
    }
    #endregion
    
    $BinPath = $PSScriptRoot
    Import-Module -FullyQualifiedName (Join-Path -Path $BinPath -ChildPath 'RotaMaster.psd1')

    #region Create new event in SQLite database
    function New-SQLiteEvent{
        [CmdletBinding()]
        param (
            [Parameter(Mandatory=$false)]
            [String]$dbPath,

            [Parameter(Mandatory=$true)]
            [String]$person,

            [Parameter(Mandatory=$false)]
            [String]$alias,

            [Parameter(Mandatory=$false)]
            [String]$type = 'Pikett',

            [Parameter(Mandatory=$true)]
            $start,   # 2025-12-01T10:00:00.0000000

            [Parameter(Mandatory=$true)]
            $end,     # 2025-12-08T10:00:00.0000000

            [Parameter(Mandatory=$true)]
            [String] $Logfile
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

            try{
                $created = Get-Date -f 'yyyy-MM-dd HH:mm:ss'
            
                $sql = "INSERT INTO events (person, type, start, end, alias, created, author) VALUES ('$($person)', '$($type)', '$($start)', '$($end)', '$($alias)', '$($created)', 'Pikett Manager')"
                $connection = New-SQLiteConnection -DataSource $dbPath
                Invoke-SqliteQuery -Connection $connection -Query $sql
                $Connection.Close()
            }catch{
                "$($function)$($params): LineNumber: $($_.InvocationInfo.ScriptLineNumber), Message: $($_.Exception.Message)" | Out-File -Append -FilePath $Logfile.Replace('informational','error') -Encoding utf8
                Write-Warning "$($function)$($params): LineNumber: $($_.InvocationInfo.ScriptLineNumber), Message: $($_.Exception.Message)"
                $Error.Clear()
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

    $BinPath = $PSScriptRoot
    $ApiPath = $($BinPath).Replace('bin','api')
    $LogPath = $($BinPath).Replace('bin','logs')
    $Logfile = Join-Path -Path $LogPath -ChildPath "informational_$(Get-Date -f 'yyyy-MM-dd').log"
    $dbName  = 'rotamaster.db'
    $dbPath  = Join-Path -Path $($ApiPath) -ChildPath $dbName

}

process{
    $csv = Import-Csv -Delimiter ';' -Path $FilePath

    Write-Host "Importing from '$($FilePath)' into OpsGenie '$($ScheduleName) - $($RotationName)' and database '$($dbName)" -ForegroundColor Green
    foreach ($item in $csv) {
        
        $userName = Get-EmailFromPerson -dbPath $dbPath -person $item.title # email!!!

        if(-not([String]::IsNullOrEmpty($userName))){
            $participants = @(
                [PSCustomObject]@{
                    type     = 'user'
                    username = $userName
                }
            )
            $rotations = @(
                [PSCustomObject]@{
                    name = $RotationName
                }
            )
            $OnCallStart    = Get-Date $item.start -f 'yyyy-MM-dd 10:00'
            $OnCallEnd      = Get-Date $item.end   -f 'yyyy-MM-dd 10:00'

            Write-Host ('[ OpsGenie ] Add {1} for {0} from {2} to {3} on {4} {5}' -f $userName, 'Pikett', $OnCallStart, $OnCallEnd, $ScheduleName, $RotationName) -ForegroundColor Green
            if($prod){
                $ret = Read-Host -Prompt 'WARNING: You are trying to import into the productive OpsGenie! Do you want to continue? [Y] Yes, [N] No'
                if($ret -match '^y'){
                    $apiKey = $env:OPS_GENIE_API_KEY
                }else{
                    Write-Host '[ OpsGenie ] Switched to the development OpsGenie.'
                    $apiKey = $env:OPS_GENIE_API_KEY_DEV
                }
            }else{
                $apiKey = $env:OPS_GENIE_API_KEY_DEV
            }
            $NewOpsGenieOverride = New-OpsGenieOverride -Schedule $ScheduleName -Rotation $rotations -startDate $OnCallStart -endDate $OnCallEnd -participants $participants -ApiKey $apiKey -Logfile $Logfile
            "$(Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'); Override created as $($NewOpsGenieOverride.data.alias)" | Out-File -Append -FilePath $Logfile -Encoding utf8
            Write-Host "[ OpsGenie ] Create override in OpsGenie as alias: $($NewOpsGenieOverride.data.alias)" -ForegroundColor Green

            if(-not([String]::IsNullOrEmpty($NewOpsGenieOverride.data.alias))){
                Write-Host ('[ SQLiteDB ] Add {1} for {0} from {2} to {3} on database {4}' -f $item.title,'Pikett', $item.start, $item.end, $dbName) -ForegroundColor Green
                New-SQLiteEvent -dbPath $dbPath -person $item.title -alias $($NewOpsGenieOverride.data.alias) -type 'Pikett' -start $item.start -end $item.end -Logfile $Logfile
            }else {
                Write-Warning '[ OpsGenie ] Override not successfully, did not import into database, please have a look into OpsGenie!'
            }
        }else {
            Write-Warning "[ SQLiteDB ] Could not evaluate the email of $($item.title), abort import for this person!"
        }
    }
    Write-Host "Import process completed." -ForegroundColor Green
}

end{
    #region Do not change this region
    Write-Verbose $('[', (Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'), ']', '[ End     ]', $function -Join ' ')
    $TimeSpan  = New-TimeSpan -Start $StartTime -End (Get-Date)
    $Formatted = $TimeSpan | ForEach-Object {
        '{1:0}h {2:0}m {3:0}s {4:000}ms' -f $_.Days, $_.Hours, $_.Minutes, $_.Seconds, $_.Milliseconds
    }
    Write-Host $('Finished in:', $Formatted -Join ' ') -ForegroundColor Green
    #endregion
}
