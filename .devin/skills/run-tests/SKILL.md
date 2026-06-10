# Run Tests

Execute the Pester test suite for the RotaMaster application.

## Description
This skill runs the Pester tests to verify the functionality of the application, particularly the login page and other components.

## Prerequisites
- PowerShell 7+ (pwsh)
- Pester module installed
- Development server running on https://localhost:8443/

## Usage
Run the following command from the project root:
```powershell
Invoke-Pester -Path ./tests/login-page.tests.ps1 -Output Detailed
```

For all tests in the tests directory:
```powershell
Invoke-Pester -Path ./tests/ -Output Detailed
```

## Test Files
- `tests/login-page.tests.ps1` - Tests for login page functionality including valid/invalid credentials

## Expected Output
Pester will output detailed test results showing:
- Test execution time
- Pass/fail status for each test
- Error details if any tests fail
- Overall test summary

## Troubleshooting
- If Pester module is missing: `Install-Module -Name Pester -Repository PSGallery`
- If tests fail due to server not running, start the server first using the start-server skill
- If credential prompts timeout, ensure you have valid test credentials ready
- SSL certificate warnings can be ignored for local development

## Notes
- The login test requires interactive credential input
- Tests use -SkipCertificateCheck to work with self-signed certificates
- Tests verify both successful login and failed login scenarios