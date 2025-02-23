Import-Module Pester

Describe "Test the Login Page" {
    BeforeAll {
        $script:validCredential = Get-Credential -Message "Enter your credentials" 
        $script:loginUrl = "https://localhost:8443/login" # Passe die URL an deine lokale Entwicklungsumgebung an

        function Invoke-Login {
            param (
                [PSCredential]$Credential,
                [string]$Url
            )

            $body = @{
                username = $Credential.UserName
                password = $Credential.GetNetworkCredential().Password
            }

            try {
                $response = Invoke-WebRequest -Uri $Url -Method Post -Body $body -SessionVariable session -UseBasicParsing -SkipCertificateCheck -MaximumRedirection 0
            }
            catch {
                $response = $_.Exception.Response
            }

            return $response
        }

        function Invoke-GetLogin {
            param (
                [string]$Url
            )

            try {
                $response = Invoke-WebRequest -Uri $Url -Method Get -UseBasicParsing -SkipCertificateCheck
            }
            catch {
                $response = $_.Exception.Response
            }

            return $response
        }
    }

    Context "check if login URL is accessible" {
        It "should return a successful response for GET request" {
            $response = Invoke-GetLogin -Url $script:loginUrl
            $response.StatusCode | Should -Be 200
        }
    }
    
    Context "check with valid credentials" {
        It "should return a successful response and redirect to /" {
            $response = Invoke-Login -Credential $script:validCredential -Url $script:loginUrl 
            $response.StatusCode | Should -Be 302
            $locationHeader = ($response.Headers).Where({$_.Key -match 'Location'}).Value
            $locationHeader | Should -Be "/"
        }
    }

    Context "check with invalid credentials" {
        It "should return an error message and redirect to /login" {
            $credential = New-Object -TypeName PSCredential -ArgumentList "invalidUser", (ConvertTo-SecureString "invalidPassword" -AsPlainText -Force)
            $response = Invoke-Login -Credential $credential -Url $script:loginUrl 
            $response.StatusCode | Should -Be 302
            $locationHeader = ($response.Headers).Where({$_.Key -match 'Location'}).Value
            $locationHeader | Should -Be "/login"
        }
    }
}

<# 
    Invoke-Pester -Path .\tests\login-page.tests.ps1 -Output Detailed
#>