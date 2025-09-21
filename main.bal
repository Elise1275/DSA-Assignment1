import ballerina/io;
import ballerina/log;

public function main() {
    log:printInfo("NUST Asset Management System CLI starting...");

    // Prompt user to login
    boolean loggedIn = promptLogin();
    if !loggedIn {
        io:println("Login failed or cancelled. Exiting.");
        return;
    }

    User? currentUserRef = getCurrentUser();
    if currentUserRef is User {
        io:println("\nWelcome to NUST Asset Management System!");
        io:println("Logged in as: " + currentUserRef.fullName + " (" + currentUserRef.role + ")");
    }

    // Main menu loop
    while true {
        displayMainMenu();
        int choice = getUserChoice();

        // Get available actions for the current user
        function()[] actions = getAvailableActions();

        if choice == 0 {
            io:println("\nThank you for using NUST Asset Management System!");
            break;
        } else if choice > 0 && choice <= actions.length() {
            function() action = actions[choice - 1];
            action();
        } else {
            displayError("Invalid choice! Please try again.");
        }
    }
}

// Get available menu actions based on user role
function getAvailableActions() returns function()[] {
    User? user = getCurrentUser();
    if user is () {
        return [];
    }

    string role = user.role;
    function()[] actions = [];

    // Asset Management - available to all roles
    actions.push(handleAssetMenu);

    // Component Management - Admin and Technician
    if role == "Administrator" || role == "Technician" {
        actions.push(handleComponentMenu);
    }

    // Maintenance Scheduling - Admin, Manager, Technician
    if role == "Administrator" || role == "Manager" || role == "Technician" {
        actions.push(handleScheduleMenu);
    }

    // Work Order Management - Admin, Manager, Technician
    if role == "Administrator" || role == "Manager" || role == "Technician" {
        actions.push(handleWorkOrderMenu);
    }

    // Reports & Analytics - available to all roles
    actions.push(handleReportsMenu);

    // System Information - available to all roles
    actions.push(displaySystemInfo);

    return actions;
}

// Display system information
function displaySystemInfo() {
    io:println("\n╔════════════════════════════════════════╗");
    io:println("║           System Information           ║");
    io:println("╠════════════════════════════════════════╣");
    io:println("║ Version:     1.0.0                     ║");
    io:println("║ Database:    In-memory                 ║");
    io:println("║ Assets:      " + padRight(assetDatabase.length().toString(), 25) + "║");
    io:println("║ Users:       1 (Demo)                  ║");
    io:println("║ Status:      Operational               ║");
    io:println("╚════════════════════════════════════════╝");
    waitForEnter();
}
