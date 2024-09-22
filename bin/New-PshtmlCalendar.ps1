<#
.SYNOPSIS
    Create new web-page

.DESCRIPTION
    Create new pode web-page with PSHTML. Contains the layout with a jumbotron, navbar, body, content, footer.
    
.EXAMPLE
    .\PSRotaMaster\bin\New-PshtmlCalendar.ps1 -Title 'PS calendar'

.EXAMPLE
    .\PSRotaMaster\bin\New-PshtmlCalendar.ps1 -Title 'PS calendar' -AssetPath '/assets'
#>

[CmdletBinding()]
param (
    #Titel of the new page, will be used for the file name
    [Parameter(Mandatory=$false)]
    [String]$Title = 'PS calendar',

    #Year to use between 1970 and 2999
    [ValidateRange(1970, 2999)]
    [Parameter(Mandatory=$true)]
    [int]$Year,

    #Month to use in de-CH culture
    [ValidateSet('Januar','Februar','März','April','Mai','Juni','Juli','August','September','Oktober','November','Dezember')]
    [Parameter(Mandatory=$true)]
    [String]$Month,

    #Asset-path, should be public/assets on the pode server
    [Parameter(Mandatory=$false)]
    [String]$AssetsPath = '/assets'
)


begin{    
    $StartTime = Get-Date
    $function = $($MyInvocation.MyCommand.Name)
    foreach($item in $PSBoundParameters.keys){
        $params = "$($params) -$($item) $($PSBoundParameters[$item])"
    }
    Write-Verbose $('[', (Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'), ']', '[ Begin   ]', "$($function)$($params)" -Join ' ')

    enum OSType {
        Linux
        Mac
        Windows
    }

    if($PSVersionTable.PSVersion.Major -lt 6){
        $CurrentOS = [OSType]::Windows
    }else{
        if($IsMacOS)  {$CurrentOS = [OSType]::Mac}
        if($IsLinux)  {$CurrentOS = [OSType]::Linux}
        if($IsWindows){$CurrentOS = [OSType]::Windows}
    }
}

process{

    #region variables
    $PodePath = Join-Path -Path $($PSScriptRoot).Replace('bin','') -ChildPath 'views'
    $PodeView = (("$($Title).pode") -replace '\s', '-')
    $OutFile  = Join-Path -Path $($PodePath) -ChildPath $($PodeView).ToLower()

    Write-Verbose "OutFile: $($OutFile)"
    Write-Verbose "AssetsPath: $($AssetsPath)"

    $ContainerStyle       = 'Container'
    $ContainerStyleFluid  = 'container-fluid'
    $HeaderColor          = '#212529'
    $PsHeaderColor        = '#012456'
    $TextColor            = '#000'
    $HeaderTitle          = $($Title)
    $BodyDescription      = "I ♥ PS Pode > This is an example for using pode and PSHTML."
    $FooterSummary        = "Based on "
    $BootstrapNavbarColor = 'bg-dark navbar-dark'

    $NavbarWebSiteLinks = [ordered]@{
        'https://github.com/tinuwalther/'                           = 'GitLab'
        'https://pshtml.readthedocs.io/en/latest/'                  = 'PSHTML'
        'https://www.w3schools.com/html/'                           = 'HTML'
        'https://getbootstrap.com/'                                 = 'Bootstrap'
    }
    #endregion variables

    #region navbar
    $navbar = {

        #region <!-- nav -->
        nav -class "navbar navbar-expand-sm $BootstrapNavbarColor sticky-top" -content {
            
            div -class $ContainerStyleFluid {
                
                a -class "navbar-brand" -href "/" -content {'»HOME'}

                # <!-- Toggler/collapsibe Button -->
                button -class "navbar-toggler" -Attributes @{
                    "type"="button"
                    "data-bs-toggle"="collapse"
                    "data-bs-target"="#collapsibleNavbar"
                } -content {
                    span -class "navbar-toggler-icon"
                }

                #region <!-- Navbar links -->
                div -class "collapse navbar-collapse" -id "collapsibleNavbar" -Content {
                    ul -class "navbar-nav" -content {                        
                        $NavbarWebSiteLinks.Keys | ForEach-Object {
                            li -class "nav-item" -content {
                                a -class "nav-link" -href $PSitem -Target _blank -content { $NavbarWebSiteLinks[$PSItem] }
                            }
                        }
                    }

                }
                #endregion Navbar links
            }
        }
        #endregion nav

    }
    #endregion navbar

    #region body
    $body = {
        body {
            
            #region Check TimeStamp and build the badge
            # . (Join-Path -Path $PSScriptRoot -ChildPath 'includes/timestamp.ps1')
            #endregion

            #region <!-- header -->
            . (Join-Path -Path $PSScriptRoot -ChildPath 'includes/header.ps1')
            #endregion header
            
            #region <!-- section -->
            section -id "section" -Content {  

                Invoke-Command -ScriptBlock $navbar

                #region <!-- content -->
                div -id "Content" -Class "$($ContainerStyleFluid)" {
                    article -Id "CalendarBox" -Content {
                        div -id 'events' -class $ContainerStyleFluid {

                        }

                        div -id 'calendar' -class $ContainerStyleFluid {
                            h1 {"$($Month) $($Year)"}
"
`$(`$monthAbbreviation = Get-MonthAbbreviation -MonthName $Month)
`$(`$MonthlyCalendar = Get-MonthCalendar -MonthName $Month -Year $Year | Select-Object @{N='Jahr';E={$Year}}, @{N='Monat';E={`$monthAbbreviation}}, *)
`$(`$SplatProperties = @{
        TableClass = 'table table-dark table-striped-columns table-responsive table-striped table-hover'
        TheadClass = 'thead-dark'
        Properties = @('Woche','Sonntag','Montag','Dienstag','Mittwoch','Donnerstag','Freitag','Samstag')
    }
)
`$(`$MonthlyCalendar | ConvertTo-PSHtmlTable @SplatProperties)
"
                        }
                    }
                }
                #endregion content
                
            }

            pre {
                'Re-builds the page: I ♥ PS > Invoke-WebRequest -Uri http://localhost:8080/api/month/next -Method Post -Body ''{"Year":2024,"Month":"Oktober"}'''
            } -Style "color:$($TextColor)"
            #endregion section
            
        }
    }
    #endregion body

    #region HTML
    $HTML = html {
        . (Join-Path -Path $PSScriptRoot -ChildPath 'includes/head.ps1')
        Invoke-Command -ScriptBlock $body
        . (Join-Path -Path $PSScriptRoot -ChildPath 'includes/footer.ps1')
    }
    #endregion html

    #region save page
    $Html | Set-Content $OutFile -Encoding utf8
    #endregion save page
}

end{
    Write-Verbose $('[', (Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'), ']', '[ End     ]', $function -Join ' ')
    $TimeSpan  = New-TimeSpan -Start $StartTime -End (Get-Date)
    $Formatted = $TimeSpan | ForEach-Object {
        '{1:0}h {2:0}m {3:0}s {4:000}ms' -f $_.Days, $_.Hours, $_.Minutes, $_.Seconds, $_.Milliseconds
    }
    Write-Verbose $('Finished in:', $Formatted -Join ' ')
    Get-Item $OutFile | Select-Object Name, DirectoryName, CreationTime, LastWriteTime | ConvertTo-Json
}
