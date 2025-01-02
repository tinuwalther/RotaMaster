@{
    Port = 8443
    Protocol = 'https'
    Server = @{
        Request = @{
            # There is a default request timeout of 30 seconds, exceeding this will force the connection to close.
            Timeout = 30
        }
        Logging = @{
            Masking = @{
                Patterns = @('Password=\w+')
            }
        }
    }
    Web = @{
        Static = @{
            Cache = @{
                Enable = $false
            }
        }
    }
}
