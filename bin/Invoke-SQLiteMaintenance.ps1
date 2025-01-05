<#
.SYNOPSIS
    This script is used to perform maintenance on the SQLite database.
.DESCRIPTION
    This script is used to perform maintenance on the SQLite database.
    The maintenance tasks include:
        - List the deleted events.
        - Remove the deleted events.
.NOTES
    https://www.sqlitetutorial.net/
    https://github.com/RamblingCookieMonster/PSSQLite/
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
    [Switch]$RemoveDatabase,

    [Parameter(Mandatory = $false)]
    [Switch]$NewDatabase,

    [Parameter(Mandatory = $false)]
    [Switch]$ListTables,

    [Parameter(Mandatory = $false)]
    [Switch]$ListViews,

    [Parameter(Mandatory = $false)]
    [String]$Query,

    [Parameter(Mandatory = $false)]
    [Switch]$ListDeletedEvents,

    [Parameter(Mandatory = $false)]
    [Switch]$RemoveDeletedEvents
)

#region Functions
function Get-DatabaseFile {
    ## Create the synopsis for the function
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    try{
        Test-Path -Path $Path
    }
    catch {
        $($_.Exception.Message)
        $Error.Clear()
    }
}

function Remove-DatabaseFile {
    ## Create the synopsis for the function
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $false)]
        [string]$StartDate,

        [Parameter(Mandatory = $false)]
        [string]$EndDate
    )
    
    try{
        Copy-Item -Path $Path -Destination ($Path.Replace('api','archiv')).Replace('.db','.bak') -Confirm:$false -PassThru | Select-Object Name, FullName
        Remove-Item -Path $Path -Confirm:$true -Force
    }
    catch {
        $($_.Exception.Message)
        $Error.Clear()
    }
}

function Get-DatabaseContent {
    ## Create the synopsis for the function
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $false)]
        [Switch]$Tables,

        [Parameter(Mandatory = $false)]
        [Switch]$Views
    )

    if($Tables -and $Views){
        $sql = "SELECT * FROM sqlite_master WHERE type='table'  AND name NOT LIKE 'sqlite_%' OR type='view' AND name NOT LIKE 'sqlite_%'"
    }else{
        if($Tables){
            $sql = "SELECT * FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';"
        }
        if($Views) {
            $sql = "SELECT * FROM sqlite_master WHERE type='view' AND name NOT LIKE 'sqlite_%'"
        }    
    }
    
    try{
        $connection = New-SQLiteConnection -DataSource $Path
        Invoke-SqliteQuery -Connection $connection -Query $sql
        $Connection.Close()
    }
    catch {
        $($_.Exception.Message)
        $Error.Clear()
    }
}

function Remove-Tables {
    ## Create the synopsis for the function
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $sql = "
    DROP TABLE IF EXISTS events;
    DROP INDEX IF EXISTS events;
    DROP TABLE IF EXISTS person;
    DROP INDEX IF EXISTS person;
    DROP TABLE IF EXISTS absence;
    DROP INDEX IF EXISTS absence;
    "

    try{
        $connection = New-SQLiteConnection -DataSource $Path
        Invoke-SqliteQuery -Connection $connection -Query $sql
        $Connection.Close()
    }
    catch {
        $($_.Exception.Message)
        $Error.Clear()
    }
}

function Remove-Views {
    ## Create the synopsis for the function
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $sql = "
    DROP VIEW IF EXISTS v_events;
    DROP VIEW IF EXISTS v_events_deleted;
    DROP VIEW IF EXISTS v_pikett;
    "

    try{
        $connection = New-SQLiteConnection -DataSource $Path
        Invoke-SqliteQuery -Connection $connection -Query $sql
        $Connection.Close()
    }
    catch {
        $($_.Exception.Message)
        $Error.Clear()
    }
}

function New-Tables {
    ## Create the synopsis for the function
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $sql = "
        -- Create the table events
        CREATE TABLE IF NOT EXISTS events(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            person TEXT NOT NULL,
            type TEXT NOT NULL,
            start TEXT NOT NULL,
            end TEXT NOT NULL,
            alias TEXT,
            active INTEGER NOT NULL DEFAULT 1,
            created TEXT NOT NULL DEFAULT current_timestamp,
            deleted TEXT,
            author TEXT NOT NULL
        );

        INSERT INTO 
            events (
                'person',
                'type',
                'start',
                'end',
                'author'
            )
            VALUES (
                'Cooper Alice',
                'Initialize DB',
                '2025-01-01 01:00',
                '2025-01-01 23:00',
                'Administrator'
            );

        -- Create the table person
        CREATE TABLE IF NOT EXISTS person(  
            id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
            login TEXT NOT NULL,
            name TEXT NOT NULL,
            firstname TEXT NOT NULL,
            email TEXT NOT NULL,
            active INTEGER NOT NULL DEFAULT 1,
            workload INTEGER NOT NULL DEFAULT 100,
            created TEXT NOT NULL DEFAULT current_timestamp,
            author TEXT NOT NULL
        );

        INSERT INTO
            person (
                'login',
                'name',
                'firstname',
                'email',
                'active',
                'workload',
                'author'
            )
            VALUES (
                'admin',
                'Cooper',
                'Alice',
                'acooper@local.com',
                0,
                0,
                'Administrator'
            );

        -- Create the table absence
        CREATE TABLE IF NOT EXISTS absence(  
            id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            created TEXT NOT NULL DEFAULT current_timestamp,
            author TEXT NOT NULL
        );

        -- Create indexes
        CREATE INDEX idx_events_person
        ON events (person);

        CREATE INDEX idx_person_login
        ON person (login);

        CREATE INDEX idx_absence_name
        ON absence (name);
    "
    try{
        $connection = New-SQLiteConnection -DataSource $Path
        Invoke-SqliteQuery -Connection $connection -Query $sql
        $Connection.Close()
    }
    catch {
        $($_.Exception.Message)
        $Error.Clear()
    }
}

function New-Views {
    ## Create the synopsis for the function
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $sql = "
        -- Create the view for events
        CREATE VIEW IF NOT EXISTS v_events
        AS 
        SELECT 
            e.id,
            e.person,
            e.type,
            e.start,
            e.end,
            e.alias,
            p.login,
            p.firstname,
            p.name,
            p.email,
            e.created,
            e.author
        FROM
            events e
        INNER JOIN person p ON (p.name || ' ' || p.firstname) = e.person
        WHERE
            e.active = 1
        ORDER BY 
            e.id ASC;

        -- Create the view for deleted events
        CREATE VIEW IF NOT EXISTS v_events_deleted
        AS 
        SELECT 
            e.id,
            e.person,
            e.type,
            e.start,
            e.end,
            e.alias,
            p.login,
            p.firstname,
            p.name,
            p.email,
            e.created,
            e.deleted,
            e.author
        FROM
            events e
        INNER JOIN person p ON (p.name || ' ' || p.firstname) = e.person
        WHERE
            e.active = 0
        ORDER BY 
            e.id ASC;

        -- Create the view for pikett
        CREATE VIEW IF NOT EXISTS v_pikett
        AS 
        SELECT 
            e.person,
            e.type,
            e.alias,
            e.start,
            e.end,
            e.deleted,
            p.login,
            p.email
        FROM
            events e
        INNER JOIN person p ON (p.name || ' ' || p.firstname) = e.person
        WHERE
            e.type = 'Pikett'
        ORDER BY 
            e.start ASC;
    "

    try{
        $connection = New-SQLiteConnection -DataSource $Path
        Invoke-SqliteQuery -Connection $connection -Query $sql
        $Connection.Close()
    }
    catch {
        $($_.Exception.Message)
        $Error.Clear()
    }
}

function Get-SqlContent {
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
        [string]$Path,

        [Parameter(Mandatory = $false)]
        [string]$Query
    )

    try{
        $connection = New-SQLiteConnection -DataSource $Path
        Invoke-SqliteQuery -Connection $connection -Query $Query
        $Connection.Close()
    }
    catch {
        $($_.Exception.Message)
        $Error.Clear()
    }
}

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
        [string]$Path,

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
        $connection = New-SQLiteConnection -DataSource $Path
        Invoke-SqliteQuery -Connection $connection -Query $sql
        $Connection.Close()
    }
    catch {
        $($_.Exception.Message)
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
        [string]$Path,

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
        $connection = New-SQLiteConnection -DataSource $Path
        Invoke-SqliteQuery -Connection $connection -Query $sql
        $Connection.Close()
    }
    catch {
        $($_.Exception.Message)
        $Error.Clear()
    }
}
#endregion

#region Main
$ApiPath = $($PSScriptRoot).Replace('bin','api')
$dbPath  = Join-Path -Path $ApiPath -ChildPath 'rotamaster.db'
if(Get-DatabaseFile -Path $dbPath){
    if($RemoveDatabase){
        Remove-DatabaseFile -Path $dbPath
    }
    if($ListTables){
        Get-DatabaseContent -Path $dbPath -Tables
    }
    if($ListViews){
        Get-DatabaseContent -Path $dbPath -Views
    }
    if(-not([String]::IsNullOrEmpty($Query))){
        Get-SqlContent -Path $dbPath -Query $Query
    }
    if($ListDeletedEvents){
        # $StartDate = (Get-Date -f 'yyyy-01-01')
        # $EndDate   = (Get-Date -f 'yyyy-12-31')
        Get-DeletedEvents -Path $dbPath | Format-Table
    }
    
    if($RemoveDeletedEvents){
        # $StartDate = (Get-Date -f 'yyyy-01-01')
        # $EndDate   = (Get-Date -f 'yyyy-12-31')
        Get-DeletedEvents -Path $dbPath | Format-Table
        Remove-DeletedEvents -Path $dbPath | Format-Table
    }
}else{
    if($NewDatabase){
        New-Tables -Path $dbPath
        New-Views -Path $dbPath
        Get-DatabaseContent -Path $dbPath -Tables -Views | Format-Table
    }
}
#endregion