# NUST Asset Management System - API Test Script
# Run this script to test all the API endpoints

Write-Host "=== NUST Asset Management System API Tests ===" -ForegroundColor Green
Write-Host ""

$baseUrl = "http://localhost:8080/api/v1"
$headers = @{"Content-Type" = "application/json"}

# Test 1: Get all assets (should be empty initially)
Write-Host "1. Testing GET /assets (should be empty initially)" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/assets" -Method GET -Headers $headers
    Write-Host "✅ Success: Found $($response.Count) assets" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 3
} catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Test 2: Create a new asset
Write-Host "2. Testing POST /assets (Create new asset)" -ForegroundColor Yellow
$asset1 = @{
    name = "3D Printer"
    faculty = "Computing & Informatics" 
    department = "Software Engineering"
    status = "ACTIVE"
    acquiredDate = "2024-03-10"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/assets" -Method POST -Headers $headers -Body $asset1
    Write-Host "✅ Success: Asset created" -ForegroundColor Green
    $assetTag1 = $response.data.assetTag
    Write-Host "Asset Tag: $assetTag1"
    $response | ConvertTo-Json -Depth 3
} catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Test 3: Create another asset for testing
Write-Host "3. Testing POST /assets (Create second asset)" -ForegroundColor Yellow
$asset2 = @{
    name = "Dell Server"
    faculty = "Engineering"
    department = "Computer Engineering" 
    status = "ACTIVE"
    acquiredDate = "2024-01-15"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/assets" -Method POST -Headers $headers -Body $asset2
    Write-Host "✅ Success: Second asset created" -ForegroundColor Green
    $assetTag2 = $response.data.assetTag
    Write-Host "Asset Tag: $assetTag2"
} catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Test 4: Get all assets (should now have 2)
Write-Host "4. Testing GET /assets (should now have 2 assets)" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/assets" -Method GET -Headers $headers
    Write-Host "✅ Success: Found $($response.Count) assets" -ForegroundColor Green
    foreach ($asset in $response) {
        Write-Host "  - $($asset.assetTag): $($asset.name) ($($asset.faculty))"
    }
} catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Test 5: Get asset by faculty
Write-Host "5. Testing GET /assets/faculty/{faculty}" -ForegroundColor Yellow
$facultyEncoded = [System.Web.HttpUtility]::UrlEncode("Computing & Informatics")
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/assets/faculty/$facultyEncoded" -Method GET -Headers $headers
    Write-Host "✅ Success: Found $($response.Count) assets in Computing & Informatics" -ForegroundColor Green
} catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Test 6: Get specific asset
Write-Host "6. Testing GET /assets/{assetTag}" -ForegroundColor Yellow
if ($assetTag1) {
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/assets/$assetTag1" -Method GET -Headers $headers
        Write-Host "✅ Success: Retrieved asset $assetTag1" -ForegroundColor Green
        Write-Host "  Name: $($response.name)"
        Write-Host "  Faculty: $($response.faculty)"
        Write-Host "  Status: $($response.status)"
    } catch {
        Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}
Write-Host ""

# Test 7: Add a component to the asset
Write-Host "7. Testing POST /assets/{assetTag}/components" -ForegroundColor Yellow
if ($assetTag1) {
    $component = @{
        name = "Print Head"
        description = "High precision print head for 3D printer"
        serialNumber = "PH-12345"
    } | ConvertTo-Json

    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/assets/$assetTag1/components" -Method POST -Headers $headers -Body $component
        Write-Host "✅ Success: Component added" -ForegroundColor Green
        Write-Host "  Component ID: $($response.data.componentId)"
        Write-Host "  Name: $($response.data.name)"
    } catch {
        Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}
Write-Host ""

# Test 8: Add a maintenance schedule (overdue for testing)
Write-Host "8. Testing POST /assets/{assetTag}/schedules" -ForegroundColor Yellow
if ($assetTag1) {
    $schedule = @{
        description = "Quarterly cleaning and calibration"
        frequency = "quarterly"
        nextDueDate = "2024-01-01"  # This is overdue
    } | ConvertTo-Json

    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/assets/$assetTag1/schedules" -Method POST -Headers $headers -Body $schedule
        Write-Host "✅ Success: Maintenance schedule added" -ForegroundColor Green
        Write-Host "  Schedule ID: $($response.data.scheduleId)"
        Write-Host "  Description: $($response.data.description)"
        Write-Host "  Due Date: $($response.data.nextDueDate)"
    } catch {
        Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}
Write-Host ""

# Test 9: Check for overdue maintenance
Write-Host "9. Testing GET /assets/overdue" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/assets/overdue" -Method GET -Headers $headers
    Write-Host "✅ Success: Found $($response.Count) assets with overdue maintenance" -ForegroundColor Green
    foreach ($asset in $response) {
        Write-Host "  - $($asset.assetTag): $($asset.name)"
        foreach ($schedule in $asset.schedules.PSObject.Properties) {
            Write-Host "    Overdue: $($schedule.Value.description) (Due: $($schedule.Value.nextDueDate))"
        }
    }
} catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Test 10: Create a work order
Write-Host "10. Testing POST /assets/{assetTag}/workorders" -ForegroundColor Yellow
if ($assetTag1) {
    $workOrder = @{
        description = "Print quality degradation - needs inspection"
        assignedTechnician = "John Smith"
    } | ConvertTo-Json

    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/assets/$assetTag1/workorders" -Method POST -Headers $headers -Body $workOrder
        Write-Host "✅ Success: Work order created" -ForegroundColor Green
        $workOrderId = $response.data.workOrderId
        Write-Host "  Work Order ID: $workOrderId"
        Write-Host "  Status: $($response.data.status)"
        Write-Host "  Assigned to: $($response.data.assignedTechnician)"
    } catch {
        Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}
Write-Host ""

# Test 11: Add a task to the work order
Write-Host "11. Testing POST /assets/{assetTag}/workorders/{workOrderId}/tasks" -ForegroundColor Yellow
if ($assetTag1 -and $workOrderId) {
    $task = @{
        description = "Replace print head component"
        assignedTo = "Jane Doe"
    } | ConvertTo-Json

    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/assets/$assetTag1/workorders/$workOrderId/tasks" -Method POST -Headers $headers -Body $task
        Write-Host "✅ Success: Task added to work order" -ForegroundColor Green
        Write-Host "  Task ID: $($response.data.taskId)"
        Write-Host "  Description: $($response.data.description)"
        Write-Host "  Assigned to: $($response.data.assignedTo)"
    } catch {
        Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}
Write-Host ""

# Test 12: Update asset
Write-Host "12. Testing PUT /assets/{assetTag} (Update asset)" -ForegroundColor Yellow
if ($assetTag1) {
    $updateData = @{
        name = "3D Printer Pro Max"
        faculty = "Computing & Informatics"
        department = "Software Engineering"
        status = "UNDER_REPAIR"
        acquiredDate = "2024-03-10"
    } | ConvertTo-Json

    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/assets/$assetTag1" -Method PUT -Headers $headers -Body $updateData
        Write-Host "✅ Success: Asset updated" -ForegroundColor Green
        Write-Host "  New name: $($response.data.name)"
        Write-Host "  New status: $($response.data.status)"
    } catch {
        Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}
Write-Host ""

# Final summary
Write-Host "=== Final Asset Summary ===" -ForegroundColor Green
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/assets" -Method GET -Headers $headers
    foreach ($asset in $response) {
        Write-Host "Asset: $($asset.assetTag) - $($asset.name) [$($asset.status)]" -ForegroundColor Cyan
        Write-Host "  Faculty: $($asset.faculty)"
        Write-Host "  Components: $($asset.components.PSObject.Properties.Count)"
        Write-Host "  Schedules: $($asset.schedules.PSObject.Properties.Count)"  
        Write-Host "  Work Orders: $($asset.workOrders.PSObject.Properties.Count)"
        Write-Host ""
    }
} catch {
    Write-Host "❌ Error getting final summary: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "=== API Testing Complete ===" -ForegroundColor Green