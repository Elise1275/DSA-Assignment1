// client.bal
import ballerina/http;
import ballerina/io;

public function testAssetManagementSystem() returns error? {
    // Create HTTP client
    http:Client assetClient = check new ("http://localhost:8080/api/v1");

    io:println("=== NUST Asset Management System Client Demo ===\n");

    // 1. Create a new asset
    io:println("1. Creating a new asset...");
    AssetRequest newAsset = {
        name: "3D Printer",
        faculty: "Computing & Informatics",
        department: "Software Engineering",
        status: "ACTIVE",
        acquiredDate: "2024-03-10"
    };

    Response createResponse = check assetClient->post("/assets", newAsset);
    if createResponse is ApiResponse {
        io:println("Asset created successfully:");
        io:println(createResponse.toString());
        io:println("");
    }

    // Get the created asset tag for further operations
    string assetTag = "";
    if createResponse is ApiResponse {
        anydata? data = createResponse?.data;
        if data is Asset {
            Asset createdAsset = data;
            assetTag = createdAsset.assetTag;
        }
    }

    // 2. View all assets
    io:println("2. Viewing all assets...");
    Asset[]|ErrorResponse allAssets = check assetClient->get("/assets");
    if allAssets is Asset[] {
        io:println("Total assets: " + allAssets.length().toString());
        foreach Asset asset in allAssets {
            io:println("- " + asset.assetTag + ": " + asset.name + " (" + asset.faculty + ")");
        }
        io:println("");
    }

    // 3. Create another asset for faculty filtering demo
    io:println("3. Creating another asset in different faculty...");
    AssetRequest serverAsset = {
        name: "Dell Server",
        faculty: "Engineering",
        department: "Computer Engineering",
        status: "ACTIVE",
        acquiredDate: "2024-01-15"
    };

    Response serverResponse = check assetClient->post("/assets", serverAsset);
    if serverResponse is ApiResponse {
        io:println("Server asset created successfully");
        io:println("");
    }

    // 4. View assets by faculty
    io:println("4. Viewing assets by faculty (Computing & Informatics)...");
    Asset[]|ErrorResponse facultyAssets = check assetClient->get("/assets/faculty/Computing%20&%20Informatics");
    if facultyAssets is Asset[] {
        io:println("Assets in Computing & Informatics: " + facultyAssets.length().toString());
        foreach Asset asset in facultyAssets {
            io:println("- " + asset.assetTag + ": " + asset.name);
        }
        io:println("");
    }

    // 5. Add a component to the asset
    if assetTag != "" {
        io:println("5. Adding a component to the asset...");
        ComponentRequest component = {
            name: "Print Head",
            description: "Main printing component",
            serialNumber: "PH-12345"
        };

        Response componentResponse = check assetClient->post("/assets/" + assetTag + "/components", component);
        if componentResponse is ApiResponse {
            io:println("Component added successfully:");
            io:println(componentResponse.toString());
            io:println("");
        }
    }

    // 6. Add a maintenance schedule (overdue for testing)
    if assetTag != "" {
        io:println("6. Adding an overdue maintenance schedule...");
        ScheduleRequest schedule = {
            description: "Quarterly cleaning and calibration",
            frequency: "quarterly",
            nextDueDate: "2024-01-01" // This is overdue
        };

        Response scheduleResponse = check assetClient->post("/assets/" + assetTag + "/schedules", schedule);
        if scheduleResponse is ApiResponse {
            io:println("Schedule added successfully:");
            io:println(scheduleResponse.toString());
            io:println("");
        }
    }

    // 7. Check for overdue maintenance
    io:println("7. Checking for overdue maintenance...");
    Asset[]|ErrorResponse overdueAssets = check assetClient->get("/assets/overdue");
    if overdueAssets is Asset[] {
        io:println("Assets with overdue maintenance: " + overdueAssets.length().toString());
        foreach Asset asset in overdueAssets {
            io:println("- " + asset.assetTag + ": " + asset.name);
            foreach MaintenanceSchedule schedule in asset.schedules {
                io:println("  Overdue schedule: " + schedule.description + " (Due: " + schedule.nextDueDate + ")");
            }
        }
        io:println("");
    }

    // 8. Create a work order
    if assetTag != "" {
        io:println("8. Creating a work order for the asset...");
        WorkOrderRequest workOrder = {
            description: "Print head replacement needed",
            assignedTechnician: "John Smith"
        };

        Response workOrderResponse = check assetClient->post("/assets/" + assetTag + "/workorders", workOrder);
        if workOrderResponse is ApiResponse {
            io:println("Work order created successfully:");
            io:println(workOrderResponse.toString());
            io:println("");
            
            // Get work order ID for task management
            anydata? workOrderData = workOrderResponse?.data;
            if workOrderData is WorkOrder {
                WorkOrder createdWorkOrder = workOrderData;
                string workOrderId = createdWorkOrder.workOrderId;
                
                // 9. Add a task to the work order
                io:println("9. Adding a task to the work order...");
                TaskRequest task = {
                    description: "Remove old print head",
                    assignedTo: "Jane Doe"
                };

                Response taskResponse = check assetClient->post("/assets/" + assetTag + "/workorders/" + workOrderId + "/tasks", task);
                if taskResponse is ApiResponse {
                    io:println("Task added successfully:");
                    io:println(taskResponse.toString());
                    io:println("");
                }
            }
        }
    }

    // 10. Update an asset
    if assetTag != "" {
        io:println("10. Updating the asset status...");
        AssetRequest updateRequest = {
            name: "3D Printer - Updated",
            faculty: "Computing & Informatics",
            department: "Software Engineering",
            status: "UNDER_REPAIR",
            acquiredDate: "2024-03-10"
        };

        Response updateResponse = check assetClient->put("/assets/" + assetTag, updateRequest);
        if updateResponse is ApiResponse {
            io:println("Asset updated successfully:");
            io:println(updateResponse.toString());
            io:println("");
        }
    }

    // 11. Final view of all assets to see changes
    io:println("11. Final view of all assets...");
    Asset[]|ErrorResponse finalAssets = check assetClient->get("/assets");
    if finalAssets is Asset[] {
        io:println("Final asset list:");
        foreach Asset asset in finalAssets {
            io:println("- " + asset.assetTag + ": " + asset.name + " [" + asset.status.toString() + "]");
            io:println("  Faculty: " + asset.faculty);
            io:println("  Components: " + asset.components.length().toString());
            io:println("  Schedules: " + asset.schedules.length().toString());
            io:println("  Work Orders: " + asset.workOrders.length().toString());
        }
    }

    io:println("\n=== Demo completed successfully! ===");
}