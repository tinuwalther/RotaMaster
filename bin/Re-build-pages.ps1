#region Re-buld pages
Invoke-WebRequest -Uri http://localhost:8080/api/pester  -Method Post -Body '["sbb.ch","admin.ch"]' | ConvertFrom-Json

Invoke-WebRequest -Uri http://localhost:8080/api/mermaid -Method Post -Body 'SELECT * FROM "classic_ESXiHosts" ORDER BY HostName' | ConvertFrom-Json

Invoke-WebRequest -Uri http://localhost:8080/api/month/next -Method Post -Body '{"Year":2024,"Month":"Oktober"}' | ConvertFrom-Json
#endregion