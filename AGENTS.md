# RotaMaster Development Guide for AI Agents

## Project Overview
RotaMaster is a web service for absence and duty scheduling, built with:
- **Backend**: PowerShell using Pode web framework
- **Frontend**: JavaScript, HTML/CSS with FullCalendar
- **Database**: SQLite with PSSQLite module
- **Integration**: OpsGenie API for on-call management

## Project Structure
```
RotaMaster/
├── PodeServer.ps1          # Main server script
├── api/                    # API endpoints and database
│   ├── rotamaster.db      # SQLite database
│   └── users.json         # User credentials
├── bin/                    # PowerShell utility scripts
├── public/                 # Static files and frontend
│   └── assets/rotamaster/ # Frontend configuration
├── views/                  # HTML views
├── tests/                  # Pester tests
├── test/                   # Additional test files
├── archiv/                 # Database backups
└── .devin/                 # Devin skills configuration
```

## Required PowerShell Modules
- **Pode** (v2.11.1+) - Web framework
- **PSSQLite** - SQLite database interaction
- **Pester** - Testing framework
- **PSScriptAnalyzer** - Code quality (optional)

## Development Skills
Available skills in `.devin/skills/`:
- `start-server` - Start the Pode development server
- `stop-server` - Stop the running Pode development server
- `run-tests` - Execute Pester test suite
- `database-init` - Initialize/reset SQLite database
- `test-api` - Test REST API endpoints
- `check-modules` - Verify and install required modules
- `opsgenie-test` - Test OpsGenie integration
- `code-quality` - Run code quality checks

## Common Development Workflows

### Starting Development
1. Run `check-modules` skill to ensure dependencies are installed
2. Run `database-init` if database needs to be reset
3. Run `start-server` to start the development server
4. Access application at https://localhost:8443/
5. Run `stop-server` when done to stop the development server

### Testing Changes
1. Run `run-tests` to execute Pester tests
2. Run `test-api` to test specific endpoints
3. Use browser to manually test UI changes
4. Run `code-quality` for code analysis

### Database Operations
- Use `database-init` for database maintenance
- Database file: `api/rotamaster.db`
- Backups stored in: `archiv/rotamaster.bak`
- Maintenance script: `bin/Invoke-SQLiteMaintenance.ps1`

### OpsGenie Integration
- Configuration: `public/assets/rotamaster/rotamaster.config.js`
- Management script: `bin/Invoke-OpsGenieMaintenace.ps1`
- Schedule creation: `bin/New-OnCallSchedule.ps1`

## API Endpoints
Key API routes (defined in PodeServer.ps1):
- Authentication: `/login`, `/logout`
- Year: `/api/year/new`
- Absence: `/api/absence/*` (CRUD)
- Person: `/api/person/*` (CRUD)  
- Events: `/api/event/*` (CRUD)
- OpsGenie: `/api/opsgenie/override/*`

## Testing
- Test framework: Pester
- Test location: `tests/` directory
- Example test: `tests/login-page.tests.ps1`
- Run tests: `Invoke-Pester -Path ./tests/ -Output Detailed`

## Code Conventions
- PowerShell: Follow standard PowerShell naming conventions
- JavaScript: ES6+ standards, FullCalendar API patterns
- Database: SQLite with views for calendar integration
- API: RESTful design with PowerShell routes

## Important Notes
- Server runs on HTTPS with self-signed certificates (use `-SkipCertificateCheck`)
- Default login credentials in `api/users.json`
- Swiss public holidays are automatically calculated
- Timezone configuration in rotamaster.config.js
- Database initialization creates sample data for testing

## Troubleshooting Common Issues
- **Server won't start**: Check port 8443 availability, verify database exists
- **Module errors**: Run `check-modules` skill to install dependencies
- **Database errors**: Use `database-init` to reset database
- **Certificate errors**: Use `-SkipCertificateCheck` for local development
- **API failures**: Verify server is running and check authentication

## Version Information
- Current version: V5.6.1 (git branch)
- Pode version: 2.11.1
- Project year: 2026
- Last updated: June 2026