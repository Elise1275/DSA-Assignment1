// reports_cli.bal - Reports and System Information CLI Functions
import ballerina/io;

// Generate asset summary report
public function generateAssetSummaryReport() {
    if !hasPermission("VIEW_ASSETS") {
        displayPermissionDenied("View Reports");
        return;
    }
    
    io:println("\n╔════════════════════════════════════════╗");
    io:println("║         Asset Summary Report           ║");
    io:println("╚════════════════════════════════════════╝");
    
    Asset[] allAssets = assetDatabase.toArray();
    
    // Count by status
    int activeCount = 0;
    int underRepairCount = 0;
    int disposedCount = 0;
    
    foreach Asset asset in allAssets {
        match asset.status {
            ACTIVE => { activeCount += 1; }
            UNDER_REPAIR => { underRepairCount += 1; }
            DISPOSED => { disposedCount += 1; }
        }
    }
    
    io:println("Total Assets: " + allAssets.length().toString());
    io:println("• Active: " + activeCount.toString());
    io:println("• Under Repair: " + underRepairCount.toString());
    io:println("• Disposed: " + disposedCount.toString());
    
    // Count components and schedules
    int totalComponents = 0;
    int totalSchedules = 0;
    int totalWorkOrders = 0;
    int overdueAssets = 0;
    
    foreach Asset asset in allAssets {
        totalComponents += asset.components.length();
        totalSchedules += asset.schedules.length();
        totalWorkOrders += asset.workOrders.length();
        
        // Check for overdue schedules
        foreach MaintenanceSchedule schedule in asset.schedules {
            if isOverdue(schedule.nextDueDate) {
                overdueAssets += 1;
                break;
            }
        }
    }
    
    io:println("\nAdditional Statistics:");
    io:println("• Total Components: " + totalComponents.toString());
    io:println("• Total Maintenance Schedules: " + totalSchedules.toString());
    io:println("• Total Work Orders: " + totalWorkOrders.toString());
    io:println("• Assets with Overdue Maintenance: " + overdueAssets.toString());
}

// Generate faculty-wise asset distribution report
public function generateFacultyReport() {
    if !hasPermission("VIEW_ASSETS") {
        displayPermissionDenied("View Reports");
        return;
    }
    
    io:println("\n╔════════════════════════════════════════╗");
    io:println("║    Faculty-wise Asset Distribution     ║");
    io:println("╚════════════════════════════════════════╝");
    
    Asset[] allAssets = assetDatabase.toArray();
    map<int> facultyCount = {};
    
    foreach Asset asset in allAssets {
        if facultyCount.hasKey(asset.faculty) {
            facultyCount[asset.faculty] = facultyCount.get(asset.faculty) + 1;
        } else {
            facultyCount[asset.faculty] = 1;
        }
    }
    
    if facultyCount.length() == 0 {
        displayInfo("No assets found for faculty distribution.");
        return;
    }
    
    foreach var [faculty, count] in facultyCount.entries() {
        io:println("• " + faculty + ": " + count.toString() + " assets");
    }
}

// Generate maintenance status report
public function generateMaintenanceReport() {
    if !hasPermission("VIEW_ASSETS") {
        displayPermissionDenied("View Reports");
        return;
    }
    
    io:println("\n╔════════════════════════════════════════╗");
    io:println("║       Maintenance Status Report        ║");
    io:println("╚════════════════════════════════════════╝");
    
    Asset[] allAssets = assetDatabase.toArray();
    int totalSchedules = 0;
    int overdueSchedules = 0;
    int onTimeSchedules = 0;
    
    foreach Asset asset in allAssets {
        foreach MaintenanceSchedule schedule in asset.schedules {
            totalSchedules += 1;
            if isOverdue(schedule.nextDueDate) {
                overdueSchedules += 1;
            } else {
                onTimeSchedules += 1;
            }
        }
    }
    
    if totalSchedules == 0 {
        displayInfo("No maintenance schedules found.");
        return;
    }
    
    io:println("Total Maintenance Schedules: " + totalSchedules.toString());
    io:println("• On Time: " + onTimeSchedules.toString());
    io:println("• Overdue: " + overdueSchedules.toString());
    
    decimal overduePercentage = 0.0;
    if totalSchedules > 0 {
        overduePercentage = <decimal>overdueSchedules / <decimal>totalSchedules * 100.0;
    }
    
    io:println("• Overdue Percentage: " + overduePercentage.toString() + "%");
    
    if overdueSchedules > 0 {
        io:println("\n⚠️  Overdue Schedules Details:");
        foreach Asset asset in allAssets {
            foreach MaintenanceSchedule schedule in asset.schedules {
                if isOverdue(schedule.nextDueDate) {
                    io:println("• " + asset.assetTag + " - " + asset.name);
                    io:println("  Schedule: " + schedule.description + " (Due: " + schedule.nextDueDate + ")");
                }
            }
        }
    }
}

// Generate work order status report
public function generateWorkOrderReport() {
    if !hasPermission("VIEW_ASSETS") {
        displayPermissionDenied("View Reports");
        return;
    }
    
    io:println("\n╔════════════════════════════════════════╗");
    io:println("║       Work Order Status Report         ║");
    io:println("╚════════════════════════════════════════╝");
    
    Asset[] allAssets = assetDatabase.toArray();
    int openCount = 0;
    int inProgressCount = 0;
    int completedCount = 0;
    int closedCount = 0;
    
    foreach Asset asset in allAssets {
        foreach WorkOrder workOrder in asset.workOrders {
            match workOrder.status {
                OPEN => { openCount += 1; }
                IN_PROGRESS => { inProgressCount += 1; }
                COMPLETED => { completedCount += 1; }
                CLOSED => { closedCount += 1; }
            }
        }
    }
    
    int totalWorkOrders = openCount + inProgressCount + completedCount + closedCount;
    
    if totalWorkOrders == 0 {
        displayInfo("No work orders found.");
        return;
    }
    
    io:println("Total Work Orders: " + totalWorkOrders.toString());
    io:println("• Open: " + openCount.toString());
    io:println("• In Progress: " + inProgressCount.toString());
    io:println("• Completed: " + completedCount.toString());
    io:println("• Closed: " + closedCount.toString());
}

// Generate assets by status report
public function generateAssetsByStatusReport() {
    if !hasPermission("VIEW_ASSETS") {
        displayPermissionDenied("View Reports");
        return;
    }
    
    io:println("\n╔════════════════════════════════════════╗");
    io:println("║         Assets by Status Report        ║");
    io:println("╚════════════════════════════════════════╝");
    
    Asset[] allAssets = assetDatabase.toArray();
    Asset[] activeAssets = [];
    Asset[] underRepairAssets = [];
    Asset[] disposedAssets = [];
    
    foreach Asset asset in allAssets {
        match asset.status {
            ACTIVE => { activeAssets.push(asset); }
            UNDER_REPAIR => { underRepairAssets.push(asset); }
            DISPOSED => { disposedAssets.push(asset); }
        }
    }
    
    // Display Active Assets
    if activeAssets.length() > 0 {
        io:println("\n✅ ACTIVE ASSETS (" + activeAssets.length().toString() + "):");
        foreach Asset asset in activeAssets {
            io:println("• " + asset.assetTag + " - " + asset.name + " (" + asset.faculty + ")");
        }
    }
    
    // Display Under Repair Assets
    if underRepairAssets.length() > 0 {
        io:println("\n🔧 UNDER REPAIR ASSETS (" + underRepairAssets.length().toString() + "):");
        foreach Asset asset in underRepairAssets {
            io:println("• " + asset.assetTag + " - " + asset.name + " (" + asset.faculty + ")");
        }
    }
    
    // Display Disposed Assets
    if disposedAssets.length() > 0 {
        io:println("\n🗑️  DISPOSED ASSETS (" + disposedAssets.length().toString() + "):");
        foreach Asset asset in disposedAssets {
            io:println("• " + asset.assetTag + " - " + asset.name + " (" + asset.faculty + ")");
        }
    }
}

// Display system information
public function displaySystemInformation() {
    User? user = getCurrentUser();
    
    io:println("\n╔════════════════════════════════════════╗");
    io:println("║          System Information            ║");
    io:println("╚════════════════════════════════════════╝");
    
    io:println("System: NUST Asset Management System");
    io:println("Version: 1.0.0");
    io:println("Platform: Ballerina 2201.12.9");
    
    if user is User {
        io:println("\nCurrent Session:");
        io:println("• User: " + user.fullName);
        io:println("• Username: " + user.username);
        io:println("• Role: " + user.role);
        
        io:println("\nPermissions for role '" + user.role + "':");
        io:println("• View Assets: " + hasPermission("VIEW_ASSETS").toString());
        io:println("• Create Assets: " + hasPermission("CREATE_ASSET").toString());
        io:println("• Update Assets: " + hasPermission("UPDATE_ASSET").toString());
        io:println("• Delete Assets: " + hasPermission("DELETE_ASSET").toString());
        io:println("• Manage Components: " + hasPermission("MANAGE_COMPONENTS").toString());
        io:println("• Manage Schedules: " + hasPermission("MANAGE_SCHEDULES").toString());
        io:println("• Manage Work Orders: " + hasPermission("MANAGE_WORKORDERS").toString());
    }
    
    // Database statistics
    Asset[] allAssets = assetDatabase.toArray();
    int totalComponents = 0;
    int totalSchedules = 0;
    int totalWorkOrders = 0;
    
    foreach Asset asset in allAssets {
        totalComponents += asset.components.length();
        totalSchedules += asset.schedules.length();
        totalWorkOrders += asset.workOrders.length();
    }
    
    io:println("\nDatabase Statistics:");
    io:println("• Total Assets: " + allAssets.length().toString());
    io:println("• Total Components: " + totalComponents.toString());
    io:println("• Total Schedules: " + totalSchedules.toString());
    io:println("• Total Work Orders: " + totalWorkOrders.toString());
    
    // Available users info
    io:println("\nSystem Users:");
    io:println("• Administrator (admin)");
    io:println("• Technician (technician)");
    io:println("• Manager (manager)"); 
    io:println("• Staff (staff)");
}

// Handle reports menu
public function handleReportsMenu() {
    while true {
        displayReportsMenu();
        int choice = getUserChoice();
        
        match choice {
            1 => { generateAssetSummaryReport(); waitForEnter(); }
            2 => { generateFacultyReport(); waitForEnter(); }
            3 => { generateMaintenanceReport(); waitForEnter(); }
            4 => { generateWorkOrderReport(); waitForEnter(); }
            5 => { generateAssetsByStatusReport(); waitForEnter(); }
            0 => { return; }
            _ => { displayError("Invalid choice! Please try again."); }
        }
    }
}