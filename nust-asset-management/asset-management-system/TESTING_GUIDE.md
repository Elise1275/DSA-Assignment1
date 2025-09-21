# NUST Asset Management System - Testing Guide

## Prerequisites
1. Make sure the service is running: `bal run`
2. Service should be available at: `http://localhost:8080/api/v1`

## Option 1: Automated Testing (Recommended)
Run the provided test script:
```powershell
.\test-api.ps1
```

## Option 2: Manual Testing with PowerShell

### Basic Asset Operations

#### 1. Get All Assets (Initially Empty)
```powershell
Invoke-RestMethod -Uri "http://localhost:8080/api/v1/assets" -Method GET -Headers @{"Content-Type" = "application/json"}
```

#### 2. Create a New Asset
```powershell
$asset = @{
    name = "3D Printer"
    faculty = "Computing & Informatics" 
    department = "Software Engineering"
    status = "ACTIVE"
    acquiredDate = "2024-03-10"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8080/api/v1/assets" -Method POST -Headers @{"Content-Type" = "application/json"} -Body $asset
```

#### 3. Get Specific Asset
```powershell
# Replace EQ-XXXXXXXX with the actual asset tag from step 2
Invoke-RestMethod -Uri "http://localhost:8080/api/v1/assets/EQ-XXXXXXXX" -Method GET -Headers @{"Content-Type" = "application/json"}
```

#### 4. Update Asset
```powershell
$updateData = @{
    name = "3D Printer Pro"
    faculty = "Computing & Informatics"
    department = "Software Engineering"
    status = "UNDER_REPAIR"
    acquiredDate = "2024-03-10"
} | ConvertTo-Json

# Replace EQ-XXXXXXXX with actual asset tag
Invoke-RestMethod -Uri "http://localhost:8080/api/v1/assets/EQ-XXXXXXXX" -Method PUT -Headers @{"Content-Type" = "application/json"} -Body $updateData
```

### Faculty Filtering

#### 5. Get Assets by Faculty
```powershell
# URL encode the faculty name
$facultyEncoded = [System.Web.HttpUtility]::UrlEncode("Computing & Informatics")
Invoke-RestMethod -Uri "http://localhost:8080/api/v1/assets/faculty/$facultyEncoded" -Method GET -Headers @{"Content-Type" = "application/json"}
```

### Component Management

#### 6. Add Component to Asset
```powershell
$component = @{
    name = "Print Head"
    description = "High precision print head"
    serialNumber = "PH-12345"
} | ConvertTo-Json

# Replace EQ-XXXXXXXX with actual asset tag
Invoke-RestMethod -Uri "http://localhost:8080/api/v1/assets/EQ-XXXXXXXX/components" -Method POST -Headers @{"Content-Type" = "application/json"} -Body $component
```

### Maintenance Scheduling

#### 7. Add Maintenance Schedule
```powershell
$schedule = @{
    description = "Quarterly maintenance"
    frequency = "quarterly"
    nextDueDate = "2024-12-01"  # Future date
} | ConvertTo-Json

# Replace EQ-XXXXXXXX with actual asset tag
Invoke-RestMethod -Uri "http://localhost:8080/api/v1/assets/EQ-XXXXXXXX/schedules" -Method POST -Headers @{"Content-Type" = "application/json"} -Body $schedule
```

#### 8. Add Overdue Schedule (for testing)
```powershell
$overdueSchedule = @{
    description = "Overdue maintenance check"
    frequency = "monthly"
    nextDueDate = "2024-01-01"  # Past date - overdue
} | ConvertTo-Json

# Replace EQ-XXXXXXXX with actual asset tag
Invoke-RestMethod -Uri "http://localhost:8080/api/v1/assets/EQ-XXXXXXXX/schedules" -Method POST -Headers @{"Content-Type" = "application/json"} -Body $overdueSchedule
```

#### 9. Check Overdue Maintenance
```powershell
Invoke-RestMethod -Uri "http://localhost:8080/api/v1/assets/overdue" -Method GET -Headers @{"Content-Type" = "application/json"}
```

### Work Order Management

#### 10. Create Work Order
```powershell
$workOrder = @{
    description = "Repair needed - print quality issues"
    assignedTechnician = "John Smith"
} | ConvertTo-Json

# Replace EQ-XXXXXXXX with actual asset tag
Invoke-RestMethod -Uri "http://localhost:8080/api/v1/assets/EQ-XXXXXXXX/workorders" -Method POST -Headers @{"Content-Type" = "application/json"} -Body $workOrder
```

#### 11. Update Work Order Status
```powershell
$statusUpdate = @{
    status = "IN_PROGRESS"
} | ConvertTo-Json

# Replace EQ-XXXXXXXX and WO-XXXXXXXX with actual IDs
Invoke-RestMethod -Uri "http://localhost:8080/api/v1/assets/EQ-XXXXXXXX/workorders/WO-XXXXXXXX/status" -Method PUT -Headers @{"Content-Type" = "application/json"} -Body $statusUpdate
```

### Task Management

#### 12. Add Task to Work Order
```powershell
$task = @{
    description = "Replace print head component"
    assignedTo = "Jane Doe"
} | ConvertTo-Json

# Replace EQ-XXXXXXXX and WO-XXXXXXXX with actual IDs
Invoke-RestMethod -Uri "http://localhost:8080/api/v1/assets/EQ-XXXXXXXX/workorders/WO-XXXXXXXX/tasks" -Method POST -Headers @{"Content-Type" = "application/json"} -Body $task
```

## Option 3: Testing with Postman or Similar Tools

Import the following requests into Postman:

### Collection: NUST Asset Management

1. **GET All Assets**
   - Method: GET
   - URL: `http://localhost:8080/api/v1/assets`

2. **POST Create Asset**
   - Method: POST
   - URL: `http://localhost:8080/api/v1/assets`
   - Headers: `Content-Type: application/json`
   - Body (JSON):
   ```json
   {
     "name": "3D Printer",
     "faculty": "Computing & Informatics",
     "department": "Software Engineering", 
     "status": "ACTIVE",
     "acquiredDate": "2024-03-10"
   }
   ```

3. **GET Assets by Faculty**
   - Method: GET
   - URL: `http://localhost:8080/api/v1/assets/faculty/Computing%20%26%20Informatics`

4. **GET Overdue Assets**
   - Method: GET
   - URL: `http://localhost:8080/api/v1/assets/overdue`

5. **POST Add Component**
   - Method: POST
   - URL: `http://localhost:8080/api/v1/assets/{assetTag}/components`
   - Headers: `Content-Type: application/json`
   - Body (JSON):
   ```json
   {
     "name": "Print Head",
     "description": "High precision print head",
     "serialNumber": "PH-12345"
   }
   ```

## Expected Results

All tests should return:
- ✅ HTTP 200 OK status
- ✅ Valid JSON responses
- ✅ Proper data structure with IDs generated
- ✅ Overdue functionality working for past dates
- ✅ Faculty filtering working correctly
- ✅ All CRUD operations functioning

## Troubleshooting

### Service Not Starting
```bash
# Make sure you're in the right directory
cd C:\Users\Ismael\Documents\nust-asset-management\asset-management-system

# Check if service is compiled
bal build

# Start service
bal run
```

### Connection Refused Errors
- Ensure service is running on port 8080
- Check Windows Firewall settings
- Verify no other service is using port 8080

### JSON Parse Errors
- Ensure Content-Type header is set to "application/json"
- Verify JSON syntax in request bodies
- Check for proper URL encoding in faculty names

## Performance Testing

For load testing, you can use the PowerShell script in a loop:
```powershell
for ($i = 1; $i -le 10; $i++) {
    Write-Host "Test Run $i"
    .\test-api.ps1
}
```