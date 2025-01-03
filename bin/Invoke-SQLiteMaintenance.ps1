<#
.SYNOPSIS
    This script is used to perform maintenance on the SQLite database.
.DESCRIPTION
    This script is used to perform maintenance on the SQLite database.
    The maintenance tasks include:
        - List the deleted events.
        - Remove the deleted events.
.PARAMETER ListDeletedEvents
    List the deleted events.
.PARAMETER RemoveDeletedEvents
    Remove the deleted events.
.EXAMPLE
    Invoke-SQLiteMaintenance -ListDeletedEvents
    List the deleted events.
.EXAMPLE
    Invoke-SQLiteMaintenance -RemoveDeletedEvents
    Remove the deleted events.
#>
[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [Switch]$ListDeletedEvents,

    [Parameter(Mandatory = $false)]
    [Switch]$RemoveDeletedEvents
)

#region Functions
function Get-DeletedEvents {
    ## Create the synopsis for the function
    <#
    .SYNOPSIS
        Get the deleted events.
    .DESCRIPTION
        This function gets the deleted events from the database.
    .EXAMPLE
        Get-DeletedEvents
        Get the deleted events from the database.
    #>
    param (
        [Parameter(Mandatory = $true)]
        [string]$dbPath,

        [Parameter(Mandatory = $false)]
        [string]$StartDate,

        [Parameter(Mandatory = $false)]
        [string]$EndDate
    )

    if($startDate -and $EndDate){
        $sql = "
        SELECT *
            FROM events
        WHERE
            strftime('%Y-%m-%d %H:%M:%S', start) >= '$($StartDate)' 
            AND strftime('%Y-%m-%d %H:%M:%S', start) <= '$($EndDate)'
            AND deleted Is Not Null;
        "
    }
    else {
        $sql = "
        SELECT *
            FROM events
        WHERE
            deleted Is Not Null;
        "
    }
    
    try{
        $connection = New-SQLiteConnection -DataSource $dbPath
        Invoke-SqliteQuery -Connection $connection -Query $sql
    }
    catch {
        $response = "$($_.Exception.Message)"
        $response
        $Error.Clear()
    }
}

function Remove-DeletedEvents {
    ## Create the synopsis for the function
    <#
    .SYNOPSIS
        Remove the deleted events.
    .DESCRIPTION
        This function removes the deleted events from the database.
    .EXAMPLE
        Remove-DeletedEvents
        Remove the deleted events from the database.
    #>
    param (
        [Parameter(Mandatory = $true)]
        [string]$dbPath,

        [Parameter(Mandatory = $false)]
        [string]$StartDate,

        [Parameter(Mandatory = $false)]
        [string]$EndDate
    )

    if($startDate -and $EndDate){
        $sql = "
        DELETE FROM events
        WHERE
            strftime('%Y-%m-%d %H:%M:%S', start) >= '$($StartDate)' 
            AND strftime('%Y-%m-%d %H:%M:%S', start) <= '$($EndDate)'
            AND deleted Is Not Null;
        "
    }
    else {
        $sql = "
        DELETE FROM events
        WHERE deleted Is Not Null;
        "
    }
    
    try{
        $connection = New-SQLiteConnection -DataSource $dbPath
        Invoke-SqliteQuery -Connection $connection -Query $sql
    }
    catch {
        $response = "$($_.Exception.Message)"
        $response
        $Error.Clear()
    }
}
#endregion

#region Main
$ApiPath = $($PSScriptRoot).Replace('bin','api')
$dbPath  = Join-Path -Path $ApiPath -ChildPath 'rotamaster.db'

if($ListDeletedEvents){
    # $StartDate = (Get-Date -f 'yyyy-01-01')
    # $EndDate   = (Get-Date -f 'yyyy-12-31')
    Get-DeletedEvents -dbPath $dbPath | Format-Table
}

if($RemoveDeletedEvents){
    # $StartDate = (Get-Date -f 'yyyy-01-01')
    # $EndDate   = (Get-Date -f 'yyyy-12-31')
    Get-DeletedEvents -dbPath $dbPath | Format-Table
    Remove-DeletedEvents -dbPath $dbPath | Format-Table
}
#endregion