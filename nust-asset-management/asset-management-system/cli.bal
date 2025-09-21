// cli.bal - Command Line Interface System
import ballerina/io;

// Display main menu
public function displayMainMenu() {
    User? user = getCurrentUser();
    if user is User {
        io:println("\n╔════════════════════════════════════════╗");
        io:println("║         NUST Asset Management          ║");
        io:println("║             Main Menu                  ║");
        io:println("╠════════════════════════════════════════╣");
        io:println("║ User: " + padRight(user.fullName, 30) + "║");
        io:println("║ Role: " + padRight(user.role, 30) + "║");
        io:println("╠════════════════════════════════════════╣");

        // Display menu options based on user role
        string role = user.role;
        int optionNumber = 1;

        // Asset Management - available to all roles
        io:println("║  " + optionNumber.toString() + ". Asset Management                  ║");
        optionNumber += 1;

        // Component Management - Admin and Technician
        if role == "Administrator" || role == "Technician" {
            io:println("║  " + optionNumber.toString() + ". Component Management               ║");
            optionNumber += 1;
        }

        // Maintenance Scheduling - Admin, Manager, Technician
        if role == "Administrator" || role == "Manager" || role == "Technician" {
            io:println("║  " + optionNumber.toString() + ". Maintenance Scheduling            ║");
            optionNumber += 1;
        }

        // Work Order Management - Admin, Manager, Technician
        if role == "Administrator" || role == "Manager" || role == "Technician" {
            io:println("║  " + optionNumber.toString() + ". Work Order Management              ║");
            optionNumber += 1;
        }

        // Reports & Analytics - available to all roles
        io:println("║  " + optionNumber.toString() + ". Reports & Analytics                ║");
        optionNumber += 1;

        // System Information - available to all roles
        io:println("║  " + optionNumber.toString() + ". System Information                 ║");
        optionNumber += 1;

        // Logout - available to all
        io:println("║  0. Logout                             ║");
        io:println("╚════════════════════════════════════════╝");
    }
}

// Display asset management submenu
public function displayAssetMenu() {
    io:println("\n╔════════════════════════════════════════╗");
    io:println("║           Asset Management             ║");
    io:println("╠════════════════════════════════════════╣");
    io:println("║  1. View All Assets                    ║");
    io:println("║  2. Create New Asset                   ║");
    io:println("║  3. Update Asset                       ║");
    io:println("║  4. Delete Asset                       ║");
    io:println("║  5. Search Asset by Tag                ║");
    io:println("║  6. Filter Assets by Faculty           ║");
    io:println("║  7. View Overdue Maintenance           ║");
    io:println("║  0. Back to Main Menu                  ║");
    io:println("╚════════════════════════════════════════╝");
}

// Display component management submenu
public function displayComponentMenu() {
    io:println("\n╔════════════════════════════════════════╗");
    io:println("║         Component Management           ║");
    io:println("╠════════════════════════════════════════╣");
    io:println("║  1. Add Component to Asset             ║");
    io:println("║  2. Remove Component from Asset        ║");
    io:println("║  3. View Asset Components              ║");
    io:println("║  0. Back to Main Menu                  ║");
    io:println("╚════════════════════════════════════════╝");
}

// Display maintenance scheduling submenu
public function displayScheduleMenu() {
    io:println("\n╔════════════════════════════════════════╗");
    io:println("║       Maintenance Scheduling           ║");
    io:println("╠════════════════════════════════════════╣");
    io:println("║  1. Add Maintenance Schedule           ║");
    io:println("║  2. Remove Maintenance Schedule        ║");
    io:println("║  3. View Asset Schedules               ║");
    io:println("║  4. View All Overdue Maintenance       ║");
    io:println("║  0. Back to Main Menu                  ║");
    io:println("╚════════════════════════════════════════╝");
}

// Display work order management submenu
public function displayWorkOrderMenu() {
    io:println("\n╔════════════════════════════════════════╗");
    io:println("║         Work Order Management          ║");
    io:println("╠════════════════════════════════════════╣");
    io:println("║  1. Create Work Order                  ║");
    io:println("║  2. Update Work Order Status           ║");
    io:println("║  3. Add Task to Work Order             ║");
    io:println("║  4. Remove Task from Work Order        ║");
    io:println("║  5. View Asset Work Orders             ║");
    io:println("║  0. Back to Main Menu                  ║");
    io:println("╚════════════════════════════════════════╝");
}

// Display reports submenu
public function displayReportsMenu() {
    io:println("\n╔════════════════════════════════════════╗");
    io:println("║         Reports & Analytics            ║");
    io:println("╠════════════════════════════════════════╣");
    io:println("║  1. Asset Summary Report               ║");
    io:println("║  2. Faculty-wise Asset Distribution    ║");
    io:println("║  3. Maintenance Status Report          ║");
    io:println("║  4. Work Order Status Report           ║");
    io:println("║  5. Assets by Status                   ║");
    io:println("║  0. Back to Main Menu                  ║");
    io:println("╚════════════════════════════════════════╝");
}

// Utility function to pad right
function padRight(string text, int length) returns string {
    if text.length() >= length {
        return text.substring(0, length);
    }
    
    string padded = text;
    int padding = length - text.length();
    int i = 0;
    while i < padding {
        padded = padded + " ";
        i += 1;
    }
    return padded;
}

// Get user choice
public function getUserChoice() returns int {
    io:print("\nEnter your choice: ");
    string input = (io:readln()).trim();
    
    int|error choice = int:fromString(input);
    if choice is int {
        return choice;
    } else {
        io:println("❌ Invalid input! Please enter a number.");
        return -1;
    }
}

// Get string input with prompt
public function getStringInput(string prompt) returns string {
    io:print(prompt + ": ");
    return (io:readln()).trim();
}

// Get asset tag input
public function getAssetTagInput() returns string {
    while true {
        string assetTag = getStringInput("Enter asset tag (e.g., EQ-12345678)");
        if assetTag != "" {
            return assetTag;
        }
        io:println("❌ Asset tag cannot be empty!");
    }
}

// Confirm action
public function confirmAction(string action) returns boolean {
    io:print("Are you sure you want to " + action + "? (y/N): ");
    string input = (io:readln()).trim().toLowerAscii();
    return input == "y" || input == "yes";
}

// Display success message
public function displaySuccess(string message) {
    io:println("✅ " + message);
}

// Display error message
public function displayError(string message) {
    io:println("❌ " + message);
}

// Display info message
public function displayInfo(string message) {
    io:println("ℹ️  " + message);
}

// Wait for user to press enter
public function waitForEnter() {
    io:print("\nPress Enter to continue...");
    _ = io:readln();
}

// Clear screen (simulate)
public function clearScreen() {
    int i = 0;
    while i < 50 {
        io:println("");
        i += 1;
    }
}

// Display asset in formatted way
public function displayAsset(Asset asset) {
    io:println("\n╔════════════════════════════════════════╗");
    io:println("║              Asset Details             ║");
    io:println("╠════════════════════════════════════════╣");
    io:println("║ Tag:        " + padRight(asset.assetTag, 25) + "║");
    io:println("║ Name:       " + padRight(asset.name, 25) + "║");
    io:println("║ Faculty:    " + padRight(asset.faculty, 25) + "║");
    io:println("║ Department: " + padRight(asset.department, 25) + "║");
    io:println("║ Status:     " + padRight(asset.status.toString(), 25) + "║");
    io:println("║ Acquired:   " + padRight(asset.acquiredDate, 25) + "║");
    io:println("║ Components: " + padRight(asset.components.length().toString(), 25) + "║");
    io:println("║ Schedules:  " + padRight(asset.schedules.length().toString(), 25) + "║");
    io:println("║ Work Orders:" + padRight(asset.workOrders.length().toString(), 25) + "║");
    io:println("╚════════════════════════════════════════╝");
}

// Display assets list
public function displayAssetsList(Asset[] assets) {
    if assets.length() == 0 {
        displayInfo("No assets found.");
        return;
    }
    
    io:println("\n╔═══════════════════════════════════════════════════════════════════════════════════════╗");
    io:println("║                                    Assets List                                           ║");
    io:println("╠═══════════════╦═══════════════════════╦══════════════════════════╦══════════════════════╣");
    io:println("║ Asset Tag     ║ Name                  ║ Faculty                  ║ Status               ║");
    io:println("╠═══════════════╬═══════════════════════╬══════════════════════════╬══════════════════════╣");
    
    foreach Asset asset in assets {
        io:println("║ " + padRight(asset.assetTag, 13) + " ║ " + 
                   padRight(asset.name, 21) + " ║ " + 
                   padRight(asset.faculty, 24) + " ║ " + 
                   padRight(asset.status.toString(), 20) + " ║");
    }
    
    io:println("╚═══════════════╩═══════════════════════╩══════════════════════════╩══════════════════════╝");
    io:println("Total assets: " + assets.length().toString());
}

// Display permission denied message
public function displayPermissionDenied(string operation) {
    User? user = getCurrentUser();
    if user is User {
        displayError("Permission denied! Your role (" + user.role + ") cannot perform: " + operation);
    } else {
        displayError("Permission denied! Please login first.");
    }
}