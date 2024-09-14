# Import-PodeWebStylesheet -Url 'psxi.css'

Set-PodeWebHomePage -Title 'Welcome to the RotaMaster App!' -Layouts @(

    #region Defaults
    $PodeRootPath = $($PSScriptRoot).Replace('pages','')
    #endregion

    New-PodeWebContainer -NoBackground -Content @(
        
        #region Module check
        $PSModule = 'pode.web'
        New-PodeWebCard -Name 'Module check' -Content @(
            New-PodeWebGrid -Cells @(
                foreach($item in $PSModule){
                    $module = (Get-Module -ListAvailable $item) | Sort-Object Version | Select-Object -Last 1
                    New-PodeWebCell -Width '100%' -Content @(
                        New-PodeWebAlert -Value "Module: $($module.Name), Version: $($module.Version)" -Type Info
                    )
                }
            )
        )
        #endregion Moduel check
    
    )

)
