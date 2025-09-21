// management_cli.bal - Component, Schedule, and Work Order Management CLI Operations
import ballerina/io;
import ballerina/uuid;
import ballerina/time;
import ballerina/log;

// Utility function for date checking (same as service.bal)
function isOverdue(string dueDateStr) returns boolean {
    time:Utc|error dueDate = time:utcFromString(dueDateStr + "T00:00:00Z");
    if dueDate is error {
        return false;
    }
    time:Utc currentTime = time:utcNow();
    decimal diffSeconds = time:utcDiffSeconds(currentTime, dueDate);
    return diffSeconds > 0d;
}

// Generate unique IDs
function generateComponentId() returns string {
    return "COMP-" + uuid:createType1AsString().substring(0, 8);
}

function generateScheduleId() returns string {
    return "SCH-" + uuid:createType1AsString().substring(0, 8);
}

function generateWorkOrderId() returns string {
    return "WO-" + uuid:createType1AsString().substring(0, 8);
}

function generateTaskId() returns string {
    return "TASK-" + uuid:createType1AsString().substring(0, 8);
}

// =============================================================================
// COMPONENT MANAGEMENT CLI FUNCTIONS
// =============================================================================

// CLI function to add component to asset
public function cliAddComponent() {
    if !hasPermission("MANAGE_COMPONENTS") {
        displayPermissionDenied("Manage Components");
        return;
    }
    
    if assetDatabase.length() == 0 {
        displayInfo("No assets available. Please create an asset first.");
        return;
    }
    
    // Show available assets
    displayInfo("Available assets:");
    cliViewAllAssets();
    
    string assetTag = getAssetTagInput();
    if !assetDatabase.hasKey(assetTag) {
        displayError("Asset not found: " + assetTag);
        return;
    }
    
    Asset asset = assetDatabase.get(assetTag);
    displayAsset(asset);
    
    io:println("\n╔════════════════════════════════════════╗");
    io:println("║           Add Component                ║");
    io:println("╚════════════════════════════════════════╝");
    
    string name = "";
    while name == "" {
        name = getStringInput("Enter component name");
        if name == "" {
            displayError("Component name cannot be empty!");
        }
    }
    
    string description = getStringInput("Enter component description (optional)");
    string serialNumber = getStringInput("Enter serial number (optional)");
    
    string componentId = generateComponentId();
    Component newComponent = {
        componentId: componentId,
        name: name,
        description: description == "" ? () : description,
        serialNumber: serialNumber == "" ? () : serialNumber
    };
    
    asset.components[componentId] = newComponent;
    assetDatabase[assetTag] = asset;
    
    displaySuccess("Component added successfully!");
    io:println("Component ID: " + componentId);
    io:println("Name: " + name);
    
    log:printInfo("Component added: " + componentId + " to asset: " + assetTag + " by user: " + (getCurrentUser()?.username ?: "unknown"));
}

// CLI function to remove component from asset
public function cliRemoveComponent() {
    if !hasPermission("MANAGE_COMPONENTS") {
        displayPermissionDenied("Manage Components");
        return;
    }
    
    if assetDatabase.length() == 0 {
        displayInfo("No assets available.");
        return;
    }
    
    // Show available assets
    displayInfo("Available assets:");
    cliViewAllAssets();
    
    string assetTag = getAssetTagInput();
    if !assetDatabase.hasKey(assetTag) {
        displayError("Asset not found: " + assetTag);
        return;
    }
    
    Asset asset = assetDatabase.get(assetTag);
    
    if asset.components.length() == 0 {
        displayInfo("No components found for this asset.");
        return;
    }
    
    // Show available components
    io:println("\nAvailable components:");
    foreach Component component in asset.components {
        io:println("• " + component.componentId + ": " + component.name);
    }
    
    string componentId = getStringInput("Enter component ID to remove");
    if !asset.components.hasKey(componentId) {
        displayError("Component not found: " + componentId);
        return;
    }
    
    Component component = asset.components.get(componentId);
    io:println("Component to remove: " + component.name);
    
    if confirmAction("remove this component") {
        _ = asset.components.remove(componentId);
        assetDatabase[assetTag] = asset;
        displaySuccess("Component removed successfully!");
        log:printInfo("Component removed: " + componentId + " from asset: " + assetTag + " by user: " + (getCurrentUser()?.username ?: "unknown"));
    } else {
        displayInfo("Component removal cancelled.");
    }
}

// CLI function to view asset components
public function cliViewAssetComponents() {
    if !hasPermission("VIEW_ASSETS") {
        displayPermissionDenied("View Assets");
        return;
    }
    
    if assetDatabase.length() == 0 {
        displayInfo("No assets available.");
        return;
    }
    
    string assetTag = getAssetTagInput();
    if !assetDatabase.hasKey(assetTag) {
        displayError("Asset not found: " + assetTag);
        return;
    }
    
    Asset asset = assetDatabase.get(assetTag);
    displayAsset(asset);
    
    if asset.components.length() == 0 {
        displayInfo("No components found for this asset.");
    } else {
        io:println("\n╔════════════════════════════════════════╗");
        io:println("║              Components                ║");
        io:println("╚════════════════════════════════════════╝");
        foreach Component component in asset.components {
            io:println("• ID: " + component.componentId);
            io:println("  Name: " + component.name);
            string? desc = component.description;
            if desc is string {
                io:println("  Description: " + desc);
            }
            string? serialNum = component.serialNumber;
            if serialNum is string {
                io:println("  Serial Number: " + serialNum);
            }
            io:println("");
        }
    }
}

// =============================================================================
// MAINTENANCE SCHEDULE CLI FUNCTIONS
// =============================================================================

// CLI function to add maintenance schedule
public function cliAddSchedule() {
    if !hasPermission("MANAGE_SCHEDULES") {
        displayPermissionDenied("Manage Schedules");
        return;
    }
    
    if assetDatabase.length() == 0 {
        displayInfo("No assets available. Please create an asset first.");
        return;
    }
    
    // Show available assets
    displayInfo("Available assets:");
    cliViewAllAssets();
    
    string assetTag = getAssetTagInput();
    if !assetDatabase.hasKey(assetTag) {
        displayError("Asset not found: " + assetTag);
        return;
    }
    
    Asset asset = assetDatabase.get(assetTag);
    displayAsset(asset);
    
    io:println("\n╔════════════════════════════════════════╗");
    io:println("║       Add Maintenance Schedule         ║");
    io:println("╚════════════════════════════════════════╝");
    
    string description = "";
    while description == "" {
        description = getStringInput("Enter schedule description");
        if description == "" {
            displayError("Description cannot be empty!");
        }
    }
    
    io:println("\nSelect frequency:");
    io:println("1. Daily");
    io:println("2. Weekly");
    io:println("3. Monthly");
    io:println("4. Quarterly");
    io:println("5. Yearly");
    io:println("6. Custom");
    
    string frequency = "";
    int freqChoice = -1;
    while freqChoice < 1 || freqChoice > 6 {
        freqChoice = getUserChoice();
        if freqChoice < 1 || freqChoice > 6 {
            displayError("Invalid choice! Please select 1-6.");
        }
    }
    
    match freqChoice {
        1 => { frequency = "daily"; }
        2 => { frequency = "weekly"; }
        3 => { frequency = "monthly"; }
        4 => { frequency = "quarterly"; }
        5 => { frequency = "yearly"; }
        6 => { frequency = getStringInput("Enter custom frequency"); }
    }
    
    string nextDueDate = "";
    while nextDueDate == "" {
        nextDueDate = getStringInput("Enter next due date (YYYY-MM-DD)");
        if nextDueDate == "" {
            displayError("Due date cannot be empty!");
        }
        // Basic date validation
        if nextDueDate.length() != 10 || nextDueDate.substring(4, 5) != "-" || nextDueDate.substring(7, 8) != "-" {
            displayError("Invalid date format! Use YYYY-MM-DD");
            nextDueDate = "";
        }
    }
    
    string scheduleId = generateScheduleId();
    MaintenanceSchedule newSchedule = {
        scheduleId: scheduleId,
        description: description,
        frequency: frequency,
        nextDueDate: nextDueDate
    };
    
    asset.schedules[scheduleId] = newSchedule;
    assetDatabase[assetTag] = asset;
    
    displaySuccess("Maintenance schedule added successfully!");
    io:println("Schedule ID: " + scheduleId);
    io:println("Description: " + description);
    io:println("Frequency: " + frequency);
    io:println("Next Due: " + nextDueDate);
    
    log:printInfo("Schedule added: " + scheduleId + " to asset: " + assetTag + " by user: " + (getCurrentUser()?.username ?: "unknown"));
}

// CLI function to remove maintenance schedule
public function cliRemoveSchedule() {
    if !hasPermission("MANAGE_SCHEDULES") {
        displayPermissionDenied("Manage Schedules");
        return;
    }
    
    if assetDatabase.length() == 0 {
        displayInfo("No assets available.");
        return;
    }
    
    string assetTag = getAssetTagInput();
    if !assetDatabase.hasKey(assetTag) {
        displayError("Asset not found: " + assetTag);
        return;
    }
    
    Asset asset = assetDatabase.get(assetTag);
    
    if asset.schedules.length() == 0 {
        displayInfo("No maintenance schedules found for this asset.");
        return;
    }
    
    // Show available schedules
    io:println("\nAvailable maintenance schedules:");
    foreach MaintenanceSchedule schedule in asset.schedules {
        io:println("• " + schedule.scheduleId + ": " + schedule.description + " (" + schedule.frequency + ")");
        io:println("  Next due: " + schedule.nextDueDate);
    }
    
    string scheduleId = getStringInput("Enter schedule ID to remove");
    if !asset.schedules.hasKey(scheduleId) {
        displayError("Schedule not found: " + scheduleId);
        return;
    }
    
    MaintenanceSchedule schedule = asset.schedules.get(scheduleId);
    io:println("Schedule to remove: " + schedule.description);
    
    if confirmAction("remove this schedule") {
        _ = asset.schedules.remove(scheduleId);
        assetDatabase[assetTag] = asset;
        displaySuccess("Schedule removed successfully!");
        log:printInfo("Schedule removed: " + scheduleId + " from asset: " + assetTag + " by user: " + (getCurrentUser()?.username ?: "unknown"));
    } else {
        displayInfo("Schedule removal cancelled.");
    }
}

// CLI function to view asset schedules
public function cliViewAssetSchedules() {
    if !hasPermission("VIEW_ASSETS") {
        displayPermissionDenied("View Assets");
        return;
    }
    
    if assetDatabase.length() == 0 {
        displayInfo("No assets available.");
        return;
    }
    
    string assetTag = getAssetTagInput();
    if !assetDatabase.hasKey(assetTag) {
        displayError("Asset not found: " + assetTag);
        return;
    }
    
    Asset asset = assetDatabase.get(assetTag);
    displayAsset(asset);
    
    if asset.schedules.length() == 0 {
        displayInfo("No maintenance schedules found for this asset.");
    } else {
        io:println("\n╔════════════════════════════════════════╗");
        io:println("║         Maintenance Schedules          ║");
        io:println("╚════════════════════════════════════════╝");
        foreach MaintenanceSchedule schedule in asset.schedules {
            io:println("• ID: " + schedule.scheduleId);
            io:println("  Description: " + schedule.description);
            io:println("  Frequency: " + schedule.frequency);
            io:println("  Next Due: " + schedule.nextDueDate);
            if isOverdue(schedule.nextDueDate) {
                io:println("  Status: ⚠️  OVERDUE");
            } else {
                io:println("  Status: ✅ On Schedule");
            }
            io:println("");
        }
    }
}

// CLI function to view all overdue maintenance
public function cliViewAllOverdueMaintenanceDetails() {
    if !hasPermission("VIEW_ASSETS") {
        displayPermissionDenied("View Assets");
        return;
    }
    
    cliViewOverdueMaintenance();
}

// =============================================================================
// WORK ORDER MANAGEMENT CLI FUNCTIONS
// =============================================================================

// CLI function to create work order
public function cliCreateWorkOrder() {
    if !hasPermission("MANAGE_WORKORDERS") {
        displayPermissionDenied("Manage Work Orders");
        return;
    }
    
    if assetDatabase.length() == 0 {
        displayInfo("No assets available. Please create an asset first.");
        return;
    }
    
    // Show available assets
    displayInfo("Available assets:");
    cliViewAllAssets();
    
    string assetTag = getAssetTagInput();
    if !assetDatabase.hasKey(assetTag) {
        displayError("Asset not found: " + assetTag);
        return;
    }
    
    Asset asset = assetDatabase.get(assetTag);
    displayAsset(asset);
    
    io:println("\n╔════════════════════════════════════════╗");
    io:println("║           Create Work Order            ║");
    io:println("╚════════════════════════════════════════╝");
    
    string description = "";
    while description == "" {
        description = getStringInput("Enter work order description");
        if description == "" {
            displayError("Description cannot be empty!");
        }
    }
    
    string assignedTechnician = getStringInput("Enter assigned technician (optional)");
    
    string workOrderId = generateWorkOrderId();
    WorkOrder newWorkOrder = {
        workOrderId: workOrderId,
        description: description,
        status: OPEN,
        createdDate: time:utcToString(time:utcNow()),
        completedDate: (),
        assignedTechnician: assignedTechnician == "" ? () : assignedTechnician,
        tasks: {}
    };
    
    asset.workOrders[workOrderId] = newWorkOrder;
    assetDatabase[assetTag] = asset;
    
    displaySuccess("Work order created successfully!");
    io:println("Work Order ID: " + workOrderId);
    io:println("Description: " + description);
    io:println("Status: " + newWorkOrder.status.toString());
    if assignedTechnician != "" {
        io:println("Assigned to: " + assignedTechnician);
    }
    
    log:printInfo("Work order created: " + workOrderId + " for asset: " + assetTag + " by user: " + (getCurrentUser()?.username ?: "unknown"));
}

// CLI function to update work order status
public function cliUpdateWorkOrderStatus() {
    if !hasPermission("MANAGE_WORKORDERS") {
        displayPermissionDenied("Manage Work Orders");
        return;
    }
    
    if assetDatabase.length() == 0 {
        displayInfo("No assets available.");
        return;
    }
    
    string assetTag = getAssetTagInput();
    if !assetDatabase.hasKey(assetTag) {
        displayError("Asset not found: " + assetTag);
        return;
    }
    
    Asset asset = assetDatabase.get(assetTag);
    
    if asset.workOrders.length() == 0 {
        displayInfo("No work orders found for this asset.");
        return;
    }
    
    // Show available work orders
    io:println("\nAvailable work orders:");
    foreach WorkOrder workOrder in asset.workOrders {
        io:println("• " + workOrder.workOrderId + ": " + workOrder.description);
        io:println("  Status: " + workOrder.status.toString());
    }
    
    string workOrderId = getStringInput("Enter work order ID to update");
    if !asset.workOrders.hasKey(workOrderId) {
        displayError("Work order not found: " + workOrderId);
        return;
    }
    
    WorkOrder workOrder = asset.workOrders.get(workOrderId);
    
    io:println("\nCurrent work order:");
    io:println("Description: " + workOrder.description);
    io:println("Current status: " + workOrder.status.toString());
    
    io:println("\nSelect new status:");
    io:println("1. OPEN");
    io:println("2. IN_PROGRESS");
    io:println("3. COMPLETED");
    io:println("4. CLOSED");
    
    WorkOrderStatus newStatus = workOrder.status;
    int statusChoice = -1;
    while statusChoice < 1 || statusChoice > 4 {
        statusChoice = getUserChoice();
        if statusChoice < 1 || statusChoice > 4 {
            displayError("Invalid choice! Please select 1-4.");
        }
    }
    
    match statusChoice {
        1 => { newStatus = OPEN; }
        2 => { newStatus = IN_PROGRESS; }
        3 => { newStatus = COMPLETED; }
        4 => { newStatus = CLOSED; }
    }
    
    workOrder.status = newStatus;
    if newStatus == COMPLETED || newStatus == CLOSED {
        workOrder.completedDate = time:utcToString(time:utcNow());
    }
    
    asset.workOrders[workOrderId] = workOrder;
    assetDatabase[assetTag] = asset;
    
    displaySuccess("Work order status updated successfully!");
    io:println("New status: " + newStatus.toString());
    
    log:printInfo("Work order status updated: " + workOrderId + " to " + newStatus.toString() + " by user: " + (getCurrentUser()?.username ?: "unknown"));
}

// Handle component management menu
public function handleComponentMenu() {
    while true {
        displayComponentMenu();
        int choice = getUserChoice();
        
        match choice {
            1 => { cliAddComponent(); waitForEnter(); }
            2 => { cliRemoveComponent(); waitForEnter(); }
            3 => { cliViewAssetComponents(); waitForEnter(); }
            0 => { return; }
            _ => { displayError("Invalid choice! Please try again."); }
        }
    }
}

// Handle schedule management menu
public function handleScheduleMenu() {
    while true {
        displayScheduleMenu();
        int choice = getUserChoice();
        
        match choice {
            1 => { cliAddSchedule(); waitForEnter(); }
            2 => { cliRemoveSchedule(); waitForEnter(); }
            3 => { cliViewAssetSchedules(); waitForEnter(); }
            4 => { cliViewAllOverdueMaintenanceDetails(); waitForEnter(); }
            0 => { return; }
            _ => { displayError("Invalid choice! Please try again."); }
        }
    }
}

// Handle work order management menu
public function handleWorkOrderMenu() {
    while true {
        displayWorkOrderMenu();
        int choice = getUserChoice();
        
        match choice {
            1 => { cliCreateWorkOrder(); waitForEnter(); }
            2 => { cliUpdateWorkOrderStatus(); waitForEnter(); }
            3 => { displayInfo("Task management coming soon..."); waitForEnter(); }
            4 => { displayInfo("Task management coming soon..."); waitForEnter(); }
            5 => { displayInfo("Work order viewing coming soon..."); waitForEnter(); }
            0 => { return; }
            _ => { displayError("Invalid choice! Please try again."); }
        }
    }
}