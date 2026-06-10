# Code Quality Checks

Perform code quality checks and linting for PowerShell and JavaScript code in the RotaMaster project.

## Description
This skill provides guidance on checking code quality, including PowerShell script analysis and JavaScript/frontend code validation.

## PowerShell Code Quality

### Run PSScriptAnalyzer on PowerShell files:
```powershell
Install-Module -Name PSScriptAnalyzer -Repository PSGallery
Invoke-ScriptAnalyzer -Path ./ -Recurse -Severity Warning,Error
```

### Analyze specific files:
```powershell
Invoke-ScriptAnalyzer -Path ./PodeServer.ps1
Invoke-ScriptAnalyzer -Path ./bin/*.ps1
```

### Check for common PowerShell issues:
- Unused variables
- Missing documentation
- Inconsistent naming conventions
- Potential security issues

## JavaScript/Frontend Code Quality

### Check JavaScript files:
```powershell
# If ESLint is configured
npm run lint
# or
npx eslint public/**/*.js
```

### Validate HTML structure:
- Check views/*.html files for proper structure
- Verify FullCalendar integration
- Check Bootstrap CSS class usage

## Project Structure Validation

### Verify required files exist:
```powershell
Test-Path ./PodeServer.ps1
Test-Path ./api/rotamaster.db
Test-Path ./bin/Invoke-SQLiteMaintenance.ps1
Test-Path ./public/assets/rotamaster/rotamaster.config.js
```

### Check directory structure:
```powershell
Get-ChildItem -Directory | Select-Object Name
```

## Expected Output
Code quality tools should report:
- Number of files analyzed
- Warning and error counts
- Specific issues found with line numbers
- Severity levels for each issue
- Suggestions for improvement

## Troubleshooting
- If PSScriptAnalyzer is not installed: `Install-Module -Name PSScriptAnalyzer -Repository PSGallery`
- If npm/ESLint is not configured, set it up in package.json
- Adjust severity levels to focus on critical issues first
- Some rules may need to be disabled for specific project conventions

## Best Practices
- Fix critical errors before warnings
- Maintain consistent naming conventions across PowerShell files
- Add comment-based help to PowerShell functions
- Follow Pode framework best practices
- Ensure JavaScript follows ES6+ standards
- Keep FullCalendar configuration consistent

## Notes
- Code quality is subjective - focus on critical issues first
- PowerShell ScriptAnalyzer rules can be customized
- Consider setting up pre-commit hooks for automated checks
- Balance code quality with development velocity