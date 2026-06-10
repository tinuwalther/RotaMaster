# Test API Endpoints

Test the RotaMaster REST API endpoints to verify functionality during development.

## Description
This skill provides guidance and commands for testing the various API endpoints of the RotaMaster application.

## Prerequisites
- Development server running on https://localhost:8443/
- Valid authentication credentials
- PowerShell or curl for testing

## API Endpoints

### Authentication
- `GET /login` - Login page
- `POST /login` - Submit login credentials
- `POST /logout` - Logout

### Year Management
- `POST /api/year/new` - Create holidays for a specific year

### Absence Management
- `POST /api/absence/create` - Create new absence
- `GET /api/absence/read/{id}` - Read absence by ID
- `PUT /api/absence/update/{id}` - Update absence
- `DELETE /api/absence/delete/{id}` - Delete absence

### Person Management
- `POST /api/person/create` - Create new person
- `GET /api/person/read/{person}` - Read person data
- `PUT /api/person/update/{id}` - Update person
- `DELETE /api/person/delete/{id}` - Delete person

### Event Management
- `POST /api/event/create` - Create new event
- `GET /api/event/read/{person}` - Read events by person
- `PUT /api/event/update/{id}` - Update event
- `DELETE /api/event/delete/{id}` - Delete event

### OpsGenie Integration
- `POST /api/opsgenie/override/create` - Create OpsGenie override
- `PUT /api/opsgenie/override/update` - Update OpsGenie override
- `DELETE /api/opsgenie/override/delete` - Delete OpsGenie override

## Usage Examples

### Test server is running:
```powershell
Invoke-WebRequest -Uri https://localhost:8443/ -UseBasicParsing -SkipCertificateCheck
```

### Create holidays for a year:
```powershell
Invoke-WebRequest -Uri https://localhost:8443/api/year/new -Method Post -Body 2026 -UseBasicParsing -SkipCertificateCheck
```

### Read events for a person:
```powershell
Invoke-WebRequest -Uri https://localhost:8443/api/event/read/john.doe -UseBasicParsing -SkipCertificateCheck
```

## Expected Output
Successful API calls should return:
- 200 OK for GET requests
- 200/201 for successful POST/PUT operations
- JSON response data where applicable
- Appropriate error messages for failures

## Troubleshooting
- Ensure server is running before testing APIs
- Use -SkipCertificateCheck for local HTTPS development
- Check authentication for protected endpoints
- Verify request body format matches API expectations
- Review server logs for detailed error information

## Notes
- All endpoints require authentication except /login
- The server uses self-signed certificates for HTTPS
- API responses are typically in JSON format
- Check PodeServer.ps1 for exact route definitions and parameters