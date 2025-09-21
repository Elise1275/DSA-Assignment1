// asset_cli.bal - Asset Management CLI Operations
import ballerina/io;
import ballerina/uuid;
import ballerina/log;

// In-memory asset database (same as service.bal)
public map<Asset> assetDatabase = {};

// Generate unique asset ID
function generateAssetId() returns string {
    return "EQ-" + uuid:createType1AsString().substring(0, 8);
}

// CLI function to view all assets
public function cliViewAllAssets() {
    if !hasPermission("VIEW_ASSETS") {
        displayPermissionDenied("View Assets");
        return;
    }
    
    Asset[] assets = assetDatabase.toArray();
    displayAssetsList(assets);
}

// CLI function to create new asset
public function cliCreateAsset() {
    if !hasPermission("CREATE_ASSET") {
        displayPermissionDenied("Create Asset");
        return;
    }
    
    io:println("\n╔════════════════════════════════════════╗");
    io:println("║            Create New Asset            ║");
    io:println("╚════════════════════════════════════════╝");
    
    string name = "";
    while name == "" {
        name = getStringInput("Enter asset name");
        if name == "" {
            displayError("Asset name cannot be empty!");
        }
    }
    
    string faculty = "";
    while faculty == "" {
        faculty = getStringInput("Enter faculty");
        if faculty == "" {
            displayError("Faculty cannot be empty!");
        }
    }
    
    string department = "";
    while department == "" {
        department = getStringInput("Enter department");
        if department == "" {
            displayError("Department cannot be empty!");
        }
    }
    
    // Status selection
    io:println("\nSelect asset status:");
    io:println("1. ACTIVE");
    io:println("2. UNDER_REPAIR");
    io:println("3. DISPOSED");
    
    AssetStatus status = ACTIVE;
    int statusChoice = -1;
    while statusChoice < 1 || statusChoice > 3 {
        statusChoice = getUserChoice();
        if statusChoice < 1 || statusChoice > 3 {
            displayError("Invalid choice! Please select 1, 2, or 3.");
        }
    }
    
    match statusChoice {
        1 => { status = ACTIVE; }
        2 => { status = UNDER_REPAIR; }
        3 => { status = DISPOSED; }
    }
    
    string acquiredDate = "";
    while acquiredDate == "" {
        acquiredDate = getStringInput("Enter acquired date (YYYY-MM-DD)");
        if acquiredDate == "" {
            displayError("Acquired date cannot be empty!");
        }
        // Basic date validation
        if acquiredDate.length() != 10 || acquiredDate.substring(4, 5) != "-" || acquiredDate.substring(7, 8) != "-" {
            displayError("Invalid date format! Use YYYY-MM-DD");
            acquiredDate = "";
        }
    }
    
    // Create the asset
    string assetTag = generateAssetId();
    Asset newAsset = {
        assetTag: assetTag,
        name: name,
        faculty: faculty,
        department: department,
        status: status,
        acquiredDate: acquiredDate,
        components: {},
        schedules: {},
        workOrders: {}
    };
    
    assetDatabase[assetTag] = newAsset;
    displaySuccess("Asset created successfully with tag: " + assetTag);
    displayAsset(newAsset);
    
    log:printInfo("Asset created: " + assetTag + " by user: " + (getCurrentUser()?.username ?: "unknown"));
}

// CLI function to update asset
public function cliUpdateAsset() {
    if !hasPermission("UPDATE_ASSET") {
        displayPermissionDenied("Update Asset");
        return;
    }
    
    if assetDatabase.length() == 0 {
        displayInfo("No assets available to update.");
        return;
    }
    
    // Show available assets first
    displayInfo("Available assets:");
    cliViewAllAssets();
    
    string assetTag = getAssetTagInput();
    
    if !assetDatabase.hasKey(assetTag) {
        displayError("Asset not found: " + assetTag);
        return;
    }
    
    Asset existingAsset = assetDatabase.get(assetTag);
    displayAsset(existingAsset);
    
    io:println("\n╔════════════════════════════════════════╗");
    io:println("║             Update Asset               ║");
    io:println("╚════════════════════════════════════════╝");
    io:println("Press Enter to keep current value, or type new value:");
    
    // Get updated values
    io:print("Name [" + existingAsset.name + "]: ");
    string newName = (io:readln()).trim();
    if newName == "" {
        newName = existingAsset.name;
    }
    
    io:print("Faculty [" + existingAsset.faculty + "]: ");
    string newFaculty = (io:readln()).trim();
    if newFaculty == "" {
        newFaculty = existingAsset.faculty;
    }
    
    io:print("Department [" + existingAsset.department + "]: ");
    string newDepartment = (io:readln()).trim();
    if newDepartment == "" {
        newDepartment = existingAsset.department;
    }
    
    // Status update
    io:println("\nCurrent status: " + existingAsset.status.toString());
    io:println("Select new status (or 0 to keep current):");
    io:println("0. Keep current (" + existingAsset.status.toString() + ")");
    io:println("1. ACTIVE");
    io:println("2. UNDER_REPAIR");
    io:println("3. DISPOSED");
    
    AssetStatus newStatus = existingAsset.status;
    int statusChoice = getUserChoice();
    
    match statusChoice {
        1 => { newStatus = ACTIVE; }
        2 => { newStatus = UNDER_REPAIR; }
        3 => { newStatus = DISPOSED; }
    }
    
    io:print("Acquired Date [" + existingAsset.acquiredDate + "]: ");
    string newAcquiredDate = (io:readln()).trim();
    if newAcquiredDate == "" {
        newAcquiredDate = existingAsset.acquiredDate;
    }
    
    // Create updated asset
    Asset updatedAsset = {
        assetTag: existingAsset.assetTag,
        name: newName,
        faculty: newFaculty,
        department: newDepartment,
        status: newStatus,
        acquiredDate: newAcquiredDate,
        components: existingAsset.components,
        schedules: existingAsset.schedules,
        workOrders: existingAsset.workOrders
    };
    
    assetDatabase[assetTag] = updatedAsset;
    displaySuccess("Asset updated successfully!");
    displayAsset(updatedAsset);
    
    log:printInfo("Asset updated: " + assetTag + " by user: " + (getCurrentUser()?.username ?: "unknown"));
}

// CLI function to delete asset
public function cliDeleteAsset() {
    if !hasPermission("DELETE_ASSET") {
        displayPermissionDenied("Delete Asset");
        return;
    }
    
    if assetDatabase.length() == 0 {
        displayInfo("No assets available to delete.");
        return;
    }
    
    // Show available assets first
    displayInfo("Available assets:");
    cliViewAllAssets();
    
    string assetTag = getAssetTagInput();
    
    if !assetDatabase.hasKey(assetTag) {
        displayError("Asset not found: " + assetTag);
        return;
    }
    
    Asset asset = assetDatabase.get(assetTag);
    displayAsset(asset);
    
    if confirmAction("delete this asset") {
        _ = assetDatabase.remove(assetTag);
        displaySuccess("Asset deleted successfully: " + assetTag);
        log:printInfo("Asset deleted: " + assetTag + " by user: " + (getCurrentUser()?.username ?: "unknown"));
    } else {
        displayInfo("Asset deletion cancelled.");
    }
}

// CLI function to search asset by tag
public function cliSearchAssetByTag() {
    if !hasPermission("VIEW_ASSETS") {
        displayPermissionDenied("View Assets");
        return;
    }
    
    string assetTag = getAssetTagInput();
    
    if !assetDatabase.hasKey(assetTag) {
        displayError("Asset not found: " + assetTag);
        return;
    }
    
    Asset asset = assetDatabase.get(assetTag);
    displayAsset(asset);
    
    // Show components if any
    if asset.components.length() > 0 {
        io:println("\n╔════════════════════════════════════════╗");
        io:println("║              Components                ║");
        io:println("╚════════════════════════════════════════╝");
        foreach Component component in asset.components {
            io:println("• " + component.name + " (ID: " + component.componentId + ")");
            string? serialNum = component.serialNumber;
            if serialNum is string {
                io:println("  Serial: " + serialNum);
            }
        }
    }
    
    // Show schedules if any
    if asset.schedules.length() > 0 {
        io:println("\n╔════════════════════════════════════════╗");
        io:println("║           Maintenance Schedules        ║");
        io:println("╚════════════════════════════════════════╝");
        foreach MaintenanceSchedule schedule in asset.schedules {
            io:println("• " + schedule.description + " (" + schedule.frequency + ")");
            io:println("  Next due: " + schedule.nextDueDate);
        }
    }
    
    // Show work orders if any
    if asset.workOrders.length() > 0 {
        io:println("\n╔════════════════════════════════════════╗");
        io:println("║             Work Orders                ║");
        io:println("╚════════════════════════════════════════╝");
        foreach WorkOrder workOrder in asset.workOrders {
            io:println("• " + workOrder.description + " [" + workOrder.status.toString() + "]");
            io:println("  Created: " + workOrder.createdDate);
        }
    }
}

// CLI function to filter assets by faculty
public function cliFilterAssetsByFaculty() {
    if !hasPermission("VIEW_ASSETS") {
        displayPermissionDenied("View Assets");
        return;
    }
    
    string faculty = getStringInput("Enter faculty name");
    if faculty == "" {
        displayError("Faculty name cannot be empty!");
        return;
    }
    
    Asset[] filteredAssets = [];
    foreach Asset asset in assetDatabase {
        if asset.faculty.toLowerAscii() == faculty.toLowerAscii() {
            filteredAssets.push(asset);
        }
    }
    
    if filteredAssets.length() == 0 {
        displayInfo("No assets found for faculty: " + faculty);
    } else {
        io:println("\nAssets for faculty: " + faculty);
        displayAssetsList(filteredAssets);
    }
}

// CLI function to view overdue maintenance
public function cliViewOverdueMaintenance() {
    if !hasPermission("VIEW_ASSETS") {
        displayPermissionDenied("View Assets");
        return;
    }
    
    Asset[] overdueAssets = [];
    foreach Asset asset in assetDatabase {
        boolean hasOverdue = false;
        foreach MaintenanceSchedule schedule in asset.schedules {
            if isOverdue(schedule.nextDueDate) {
                hasOverdue = true;
                break;
            }
        }
        if hasOverdue {
            overdueAssets.push(asset);
        }
    }
    
    if overdueAssets.length() == 0 {
        displayInfo("No assets with overdue maintenance found.");
    } else {
        io:println("\n⚠️  Assets with overdue maintenance:");
        displayAssetsList(overdueAssets);
        
        // Show details of overdue schedules
        io:println("\n╔════════════════════════════════════════╗");
        io:println("║         Overdue Schedule Details       ║");
        io:println("╚════════════════════════════════════════╝");
        
        foreach Asset asset in overdueAssets {
            foreach MaintenanceSchedule schedule in asset.schedules {
                if isOverdue(schedule.nextDueDate) {
                    io:println("Asset: " + asset.assetTag + " - " + asset.name);
                    io:println("  📅 " + schedule.description + " (Due: " + schedule.nextDueDate + ")");
                }
            }
        }
    }
}

// Handle asset management menu
public function handleAssetMenu() {
    while true {
        displayAssetMenu();
        int choice = getUserChoice();
        
        match choice {
            1 => { cliViewAllAssets(); waitForEnter(); }
            2 => { cliCreateAsset(); waitForEnter(); }
            3 => { cliUpdateAsset(); waitForEnter(); }
            4 => { cliDeleteAsset(); waitForEnter(); }
            5 => { cliSearchAssetByTag(); waitForEnter(); }
            6 => { cliFilterAssetsByFaculty(); waitForEnter(); }
            7 => { cliViewOverdueMaintenance(); waitForEnter(); }
            0 => { return; }
            _ => { displayError("Invalid choice! Please try again."); }
        }
    }
}