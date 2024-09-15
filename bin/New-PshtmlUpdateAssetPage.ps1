<#
.SYNOPSIS
    Create new web-page

.DESCRIPTION
    Create new pode web-page with PSHTML. Contains the layout with a jumbotron, navbar, body, content, footer.
    
.EXAMPLE
    .\PodePSHTML\bin\New-PshtmlUpdateAssetPage.ps1 -Title 'Update Assets'

.EXAMPLE
    .\PodePSHTML\bin\New-PshtmlUpdateAssetPage.ps1 -Title 'Update Assets' -AssetPath '/assets'
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

    $ContainerStyle       = 'Container'
    $ContainerStyleFluid  = 'container-fluid'
    $HeaderColor          = '#212529'
    $PsHeaderColor        = '#012456'
    $TextColor            = '#000'
    $HeaderTitle          = $($Title)
    $BodyDescription      = "I ♥ PS Pode > This is an example for using pode and PSHTML, requested by $($Request)."
    $FooterSummary        = "Based on "
    $BootstrapNavbarColor = 'bg-dark navbar-dark'
    #endregion variables

    #region Update Assets
    $BootstrapCssPath = Join-Path -Path $($PSScriptRoot).Replace('bin','public') -ChildPath 'assets/BootStrap/bootstrap.min.css'
    $BootstrapJsPath  = Join-Path -Path $($PSScriptRoot).Replace('bin','public') -ChildPath 'assets/BootStrap/bootstrap.bundle.min.js'
    if($Request -match 'api'){
        $getbootstrap     = Invoke-WebRequest -Uri 'https://getbootstrap.com/'
        $regexCss         = 'https\:\/\/cdn\.jsdelivr\.net\/npm\/bootstrap\@[0-9]\.[0-9]\.[0-9]\/dist\/css\/bootstrap\.min\.css'
        $uriCss           = if($getbootstrap.Content -match $regexCss){$Matches[0]}
        Invoke-WebRequest -Uri $uriCss -OutFile $BootstrapCssPath -PassThru | Select-Object StatusCode, Content

        $regexJs          = 'https\:\/\/cdn\.jsdelivr\.net\/npm\/bootstrap\@[0-9]\.[0-9]\.[0-9]\/dist\/js\/bootstrap\.bundle\.min\.js'
        $uriJs            = if($getbootstrap.Content -match $regexJs){$Matches[0]}
        Invoke-WebRequest -Uri $uriJs -OutFile $BootstrapJsPath -PassThru | Select-Object StatusCode, Content
    }
    #endregion Update Assets

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

                        # <!-- StaticLink -->
                        li -class "nav-item" -content {
                            a -class "nav-link" -href "#Bootstrap" -content { 'Bootstrap' }
                        }
                        
                        # <!-- Navbar Dropdown -->
                        li -class "nav-item dropdown" -Content {

                            button -class "nav-link dropdown-toggle btn btn-sm-outline" -Attributes @{
                                "type"="button"
                                "data-bs-toggle"="dropdown"
                            } -Content { 'Packages' }

                            ul -class "dropdown-menu $BootstrapNavbarColor" {
                                li -class "nav-item" -content {
                                    a -class "nav-link" -href "#Packages" -content { 'Packages' }
                                }

                                li -class "dropdown-item $BootstrapNavbarColor" -Content {
                                    a -class "nav-link" -href "#UpdJQuery" -content { 'Update Jquery' }
                                }
                                li -class "dropdown-item $BootstrapNavbarColor" -Content {
                                    a -class "nav-link" -href "#UpdateChart" -content { 'Update Chart' }
                                }
                                li -class "dropdown-item $BootstrapNavbarColor" -Content {
                                    a -class "nav-link" -href "#UpdateMermaid" -content { 'Update Mermaid' }
                                }
                            }    
                            li -class "nav-item" -content {
                                a -class "nav-link" -href '/help' -content { 'Help' }
                            }                            
                        }
                        # <!-- Navbar Dropdown -->
                        
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
            . (Join-Path -Path $PSScriptRoot -ChildPath 'includes/timestamp.ps1')
            #endregion

            #region <!-- header -->
            . (Join-Path -Path $PSScriptRoot -ChildPath 'includes/header.ps1')
            #endregion header
            
            #region <!-- section -->
            section -id "section" -Content {  

                Invoke-Command -ScriptBlock $navbar

                #region <!-- content -->
                div -id "Content" -Class "$($ContainerStyle)" {
                
                    article -Id "Bootstrap" -Content {

                        h1 {'Bootstrap'} -Style "color:$($HeaderColor)"

                        p {
                            if(Test-Path  $BootstrapJsPath){
                                $BootstrapJsString  = Get-Content -Path $BootstrapJsPath -TotalCount 2
                                $BootstrapJsVersion = [regex]::Match($BootstrapJsString, '\d\.\d\.\d')
                                b {"Current JavaScript version: $($BootstrapJsVersion)"}
                            }
                            
                            if(Test-Path  $BootstrapCssPath){
                                $BootstrapCssString  = Get-Content -Path $BootstrapCssPath -TotalCount 2
                                $BootstrapCssVersion = [regex]::Match($BootstrapCssString, '\d\.\d\.\d')
                                b {", current CSS version: $($BootstrapCssVersion)"}
                            }
                        } -Style "color:#50C878"

                        h2 -id 'UpdateBootstrap' {'How to update Bootstrap'} -Style "color:$($HeaderColor)"

                        p {
                            'Open '
                            a -href "https://getbootstrap.com/" -Target _blank -content { 'Bootstrap' }
                            " and scroll down to "; b {'Include via CDN.'}
                        } -Style "color:$($TextColor)"

                        p {
                            "Browse to the URL in link href of the bootstrap.min.css, mark the whole content, and copy & paste the content in to your bootstrap.min.css-file."
                        } -Style "color:$($TextColor)"

                        pre {
                            "&#36;response = Invoke-WebRequest -Uri 'https://getbootstrap.com/'"
                        } -Style "color:$($TextColor)"
                        
                        pre {
                            "&#36;regex = 'https\:\/\/cdn\.jsdelivr\.net\/npm\/bootstrap\@[0-9]\.[0-9]\.[0-9]\/dist\/css\/bootstrap\.min\.css'"
                        } -Style "color:$($TextColor)"
                        
                        pre {
                            "&#36;uri = if(&#36;response.Content -match &#36;regex){&#36;Matches[0]}"
                        } -Style "color:$($TextColor)"
                        
                        pre {
                            "Invoke-WebRequest -Uri &#36;uri -OutFile &#36;BootstrapCssPath -PassThru"
                        } -Style "color:$($TextColor)"

                        p {
                            "Browse to the URL in script src of the bootstrap.bundle.min.js, mark the whole content, and copy & paste the content in to your bootstrap.bundle.min.js-file."
                        } -Style "color:$($TextColor)"

                        pre {
                            "&#36;response = Invoke-WebRequest -Uri 'https://getbootstrap.com/'"
                        } -Style "color:$($TextColor)"
                        
                        pre {
                            "&#36;regex = 'https\:\/\/cdn\.jsdelivr\.net\/npm\/bootstrap\@[0-9]\.[0-9]\.[0-9]\/dist\/js\/bootstrap\.bundle\.min\.js'"
                        } -Style "color:$($TextColor)"
                        
                        pre {
                            "&#36;uri = if(&#36;response.Content -match &#36;regex){&#36;Matches[0]}"
                        } -Style "color:$($TextColor)"
                        
                        pre {
                            "Invoke-WebRequest -Uri &#36;uri -OutFile &#36;BootstrapJsPath -PassThru"
                        } -Style "color:$($TextColor)"

                    }

                }

                hr

                div -id "Content" -Class "$($ContainerStyle)" {

                    article -Id "Packages" -Content {

                        h1 {"NPM Packages"} -Style "color:$($HeaderColor)"

                        p {
                            $JQueryJsPath = $(Join-Path -Path $($PSScriptRoot).Replace('bin','public') -ChildPath 'assets/Jquery/jquery.min.js')
                            if(Test-Path  $JQueryJsPath){
                                $JQueryJsString  = Get-Content -Path $JQueryJsPath -TotalCount 2
                                $JQueryJsVersion = [regex]::Match($JQueryJsString, '\d\.\d\.\d')
                                b {"Current Jquery version: $($JQueryJsVersion)"}
                            }

                            $ChartJsPath = $(Join-Path -Path $($PSScriptRoot).Replace('bin','public') -ChildPath 'assets/Chartjs/Chart.bundle.min.js')
                            if(Test-Path  $ChartJsPath){
                                $ChartJsString  = Get-Content -Path $ChartJsPath -TotalCount 2
                                $ChartJsVersion = [regex]::Match($ChartJsString, '\d\.\d\.\d')
                                b {", current Chart version: $($ChartJsVersion)"}
                            }

                            # $MermaidJsPath = $(Join-Path -Path $($PSScriptRoot).Replace('bin','public') -ChildPath 'assets/Chartjs/Chart.bundle.min.js')
                            # if(Test-Path  $ChartJsPath){
                            #     $MermaidJsString  = Get-Content -Path $MermaidJsPath -TotalCount 2
                            #     $MermaidJsVersion = [regex]::Match($MermaidJsString, '\d\.\d\.\d')
                            #     b {", current mermaid version: $($MermaidJsVersion)"}
                            # }
                            
                        } -Style "color:#50C878"

                    }

                    article -Id "CDNPKG" -Content {

                        h2 {"CDNPKG"} -Style "color:$($HeaderColor)"

                        p {
                            "CDNPKG is like a search engine but only for web assets (js, css, fonts etc.)."
                        } -Style "color:$($TextColor)"

                        p {
                            "The primary goal is to help developers to find their web assets more easily for production or development/test."
                        } -Style "color:$($TextColor)"

                        p {
                            a -href "https://www.cdnpkg.com/Chart.js/file/Chart.bundle.min.js/" -Target _blank -content { 'chart.bundle.min.js' }
                            ' | '
                            a -href "https://www.cdnpkg.com/jquery/file/jquery.min.js/" -Target _blank -content { 'jquery.min.js' }
                            ' | '
                            a -href "https://www.cdnpkg.com/mermaid?id=87189" -Target _blank -content { 'mermaid' }
                        } -Style "color:$($TextColor)"

                    }

                    article -Id "UNPKG" -Content {

                        h2 {"UNPKG"} -Style "color:$($HeaderColor)"

                        p {
                            "UNPKG is a fast, global content delivery network for everything on npm."
                        } -Style "color:$($TextColor)"

                        p {
                            a -href "https://unpkg.com/browse/jquery.min.js/" -Target _blank -content { 'jquery.min.js' }
                            ' | '
                            a -href "https://unpkg.com/mermaid/" -Target _blank -content { 'mermaid' }
                        } -Style "color:$($TextColor)"
                    }
                    
                    article -Content {

                        h2 -Id "UpdJQuery" {"How to update JQuery"} -Style "color:$($HeaderColor)"

                        p {
                            'Open '
                            a -href "https://www.cdnpkg.com/jquery/file/jquery.min.js/" -Target _blank -content { 'jquery.min.js' }
                            ", find the latest version, mark the whole content, and copy & paste the content in to your jquery.min.js-file"
                        } -Style "color:$($TextColor)"

                        h2 -Id "UpdateChart" {"How to update Chart Bundle"} -Style "color:$($HeaderColor)"

                        p {
                            'Open '
                            a -href "https://www.cdnpkg.com/Chart.js/file/Chart.bundle.min.js/" -Target _blank -content { 'chart.bundle.min.js' }
                            ", find the latest version, mark the whole content, and copy & paste the content in to your Chart.bundle.min.js-file"
                        } -Style "color:$($TextColor)"

                        h2 -Id "UpdateMermaid" {"How to update Mermaid"} -Style "color:$($HeaderColor)"

                        p {
                            'Open '
                            a -href "https://www.cdnpkg.com/mermaid?id=87189" -Target _blank -content { 'mermaid.min.js' }
                            ", find the latest version, mark the whole content, and copy & paste the content in to your mermaid.min.js-file"
                        } -Style "color:$($TextColor)"

                    }

                }
                #endregion column

            }

            pre {
                'Re-builds the page: I ♥ PS > Invoke-WebRequest -Uri http://localhost:8080/api/asset -Method Post'
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