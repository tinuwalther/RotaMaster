<#
.SYNOPSIS
    Create new web-page

.DESCRIPTION
    Create new pode web-page with PSHTML. Contains the layout with a jumbotron, navbar, body, content, footer.
    
.EXAMPLE
    .\PodePSHTML\bin\New-PshtmlIndexPage.ps1 -Title 'Index'

.EXAMPLE
    .\PodePSHTML\bin\New-PshtmlIndexPage.ps1 -Title 'Index' -AssetPath '/assets'
#>

[CmdletBinding()]
param (
    #Titel of the new page, will be used for the file name
    [Parameter(Mandatory=$true)]
    [String]$Title,

    #Requested by API or FileWatcher
    [Parameter(Mandatory=$true)]
    [String]$Request,

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
    $OutFile  = Join-Path -Path $($PodePath) -ChildPath $($PodeView)

    Write-Verbose "OutFile: $($OutFile)"
    Write-Verbose "AssetsPath: $($AssetsPath)"

    $ContainerStyleFluid  = 'container-fluid'
    $TextColor            = '#000'
    $CardHeaderColor      = '#fff'
    $CardTitleColor       = '#fff'
    $CardButtonColor      = '#fff'
    $PsHeaderColor        = '#012456'
    $BootstrapNavbarColor = 'bg-dark navbar-dark'

    $NavbarWebSiteLinks = [ordered]@{
        'https://github.com/tinuwalther/'                           = 'GitLab'
        'https://pshtml.readthedocs.io/en/latest/'                  = 'PSHTML'
        'https://github.com/jdhitsolutions/MySQLite'                = 'mySQLite'
        'https://pester.dev/'                                       = 'Pester'
        'https://www.w3schools.com/html/'                           = 'HTML'
        'https://getbootstrap.com/'                                 = 'Bootstrap'
        'https://www.cdnpkg.com/jquery/file/jquery.min.js/'         = 'JQuery'
        'https://www.cdnpkg.com/Chart.js/file/Chart.bundle.min.js/' = 'Chart'
    }

    $CardStyle = 'card bg-secondary mb-4 rounded-3 shadow-sm'
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
                        li -class "nav-item" -content {
                            a -class "nav-link" -href '/help' -content { 'Help' }
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

            # includes code from external script for --> header
            . (Join-Path -Path $PSScriptRoot -ChildPath 'includes/header.ps1')
            
            #region <!-- section -->
            section -id "section" -Content {  

                Invoke-Command -ScriptBlock $navbar

                #region <!-- content -->
                div -Class $ContainerStyleFluid {
                    article -Id "Boxes" -Content {
                        
                        h2 {'Calendar'} -Style "color:$($HeaderColor)"

                        div -Class "col-md" {
                            "Welcome to the jungel!"
                        } -Style "color:$($CardHeaderColor)"
                        
                        pre {
                            "New-Item ./PSRotaMster/upload -Force -Name index.txt # re-builds the pode page. On load, the page calculate the age of it self and display a green or red badge."
                        } -Style "color:$($TextColor)"
    
                    }
                }
                #endregion column

            }
            #endregion section
            
        }
    }
    #endregion body

    #region HTML
    $HTML = html {
        # includes code from external script for --> head
        . (Join-Path -Path $PSScriptRoot -ChildPath 'includes/head.ps1')

        Invoke-Command -ScriptBlock $body

        # includes code from external script for --> footer
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
