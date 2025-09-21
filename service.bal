// service.bal
import ballerina/http;
import ballerina/time;
import ballerina/uuid;
import ballerina/log;

// Note: This service is not used in CLI mode
// Database and utility functions are now in asset_cli.bal and management_cli.bal

// Utility function to generate unique IDs (for service mode)
function generateId() returns string {
    return uuid:createType1AsString();
}

// Service mode asset database (separate from CLI)
map<Asset> serviceAssetDatabase = {};

// Utility function to parse date and check if overdue (for service mode)
function isServiceOverdue(string dueDateStr) returns boolean {
    time:Utc|error dueDate = time:utcFromString(dueDateStr + "T00:00:00Z");
    if dueDate is error {
        return false;
    }
    time:Utc currentTime = time:utcNow();
    decimal diffSeconds = time:utcDiffSeconds(currentTime, dueDate);
    return diffSeconds > 0d;
}

service /api/v1 on new http:Listener(8080) {

    // Get all assets
    resource function get assets() returns Asset[]|ErrorResponse {
        return serviceAssetDatabase.toArray();
    }

    // Get assets by faculty
    resource function get assets/faculty/[string faculty]() returns Asset[]|ErrorResponse {
        Asset[] filteredAssets = [];
        foreach Asset asset in serviceAssetDatabase {
            if asset.faculty == faculty {
                filteredAssets.push(asset);
            }
        }
        return filteredAssets;
    }

    // Get overdue maintenance items
    resource function get assets/overdue() returns Asset[]|ErrorResponse {
        Asset[] overdueAssets = [];
        foreach Asset asset in serviceAssetDatabase {
            boolean hasOverdue = false;
            foreach MaintenanceSchedule schedule in asset.schedules {
                if isServiceOverdue(schedule.nextDueDate) {
                    hasOverdue = true;
                    break;
                }
            }
            if hasOverdue {
                overdueAssets.push(asset);
            }
        }
        return overdueAssets;
    }

    // Get specific asset
    resource function get assets/[string assetTag]() returns Asset|ErrorResponse {
        if serviceAssetDatabase.hasKey(assetTag) {
            return serviceAssetDatabase.get(assetTag);
        }
        ErrorResponse errorResponse = {message: "Asset not found", 'error: "NOT_FOUND"};
        return errorResponse;
    }

    // Create new asset
    resource function post assets(AssetRequest assetRequest) returns Response {
        string assetTag = "EQ-" + generateId().substring(0, 8);
        
        // Parse status properly
        AssetStatus assetStatus = ACTIVE; // Default
        if assetRequest.status is string {
            if assetRequest.status == "UNDER_REPAIR" {
                assetStatus = UNDER_REPAIR;
            } else if assetRequest.status == "DISPOSED" {
                assetStatus = DISPOSED;
            }
        }
        
        Asset newAsset = {
            assetTag: assetTag,
            name: assetRequest.name,
            faculty: assetRequest.faculty,
            department: assetRequest.department,
            status: assetStatus,
            acquiredDate: assetRequest.acquiredDate,
            components: {},
            schedules: {},
            workOrders: {}
        };

        serviceAssetDatabase[assetTag] = newAsset;
        log:printInfo("Asset created: " + assetTag);
        
        ApiResponse response = {
            message: "Asset created successfully",
            data: newAsset
        };
        return response;
    }

    // Update existing asset
    resource function put assets/[string assetTag](AssetRequest assetRequest) returns Response {
        if !serviceAssetDatabase.hasKey(assetTag) {
            ErrorResponse errorResponse = {message: "Asset not found", 'error: "NOT_FOUND"};
            return errorResponse;
        }

        Asset existingAsset = serviceAssetDatabase.get(assetTag);
        
        // Parse status properly
        AssetStatus assetStatus = ACTIVE; // Default
        if assetRequest.status is string {
            if assetRequest.status == "UNDER_REPAIR" {
                assetStatus = UNDER_REPAIR;
            } else if assetRequest.status == "DISPOSED" {
                assetStatus = DISPOSED;
            }
        }
        
        Asset updatedAsset = {
            assetTag: existingAsset.assetTag,
            name: assetRequest.name,
            faculty: assetRequest.faculty,
            department: assetRequest.department,
            status: assetStatus,
            acquiredDate: assetRequest.acquiredDate,
            components: existingAsset.components,
            schedules: existingAsset.schedules,
            workOrders: existingAsset.workOrders
        };

        serviceAssetDatabase[assetTag] = updatedAsset;
        log:printInfo("Asset updated: " + assetTag);
        
        ApiResponse response = {
            message: "Asset updated successfully",
            data: updatedAsset
        };
        return response;
    }

    // Delete asset
    resource function delete assets/[string assetTag]() returns Response {
        if !serviceAssetDatabase.hasKey(assetTag) {
            ErrorResponse errorResponse = {message: "Asset not found", 'error: "NOT_FOUND"};
            return errorResponse;
        }

        _ = serviceAssetDatabase.remove(assetTag);
        log:printInfo("Asset deleted: " + assetTag);
        
        ApiResponse response = {message: "Asset deleted successfully"};
        return response;
    }

    // COMPONENT MANAGEMENT

    // Add component to asset
    resource function post assets/[string assetTag]/components(ComponentRequest componentRequest) returns Response {
        if !serviceAssetDatabase.hasKey(assetTag) {
            ErrorResponse errorResponse = {message: "Asset not found", 'error: "NOT_FOUND"};
            return errorResponse;
        }

        Asset asset = serviceAssetDatabase.get(assetTag);
        string componentId = "COMP-" + generateId().substring(0, 8);
        
        Component newComponent = {
            componentId: componentId,
            name: componentRequest.name,
            description: componentRequest.description,
            serialNumber: componentRequest.serialNumber
        };

        asset.components[componentId] = newComponent;
        serviceAssetDatabase[assetTag] = asset;
        
        ApiResponse response = {
            message: "Component added successfully",
            data: newComponent
        };
        return response;
    }

    // Remove component from asset
    resource function delete assets/[string assetTag]/components/[string componentId]() returns Response {
        if !serviceAssetDatabase.hasKey(assetTag) {
            ErrorResponse errorResponse = {message: "Asset not found", 'error: "NOT_FOUND"};
            return errorResponse;
        }

        Asset asset = serviceAssetDatabase.get(assetTag);
        if !asset.components.hasKey(componentId) {
            ErrorResponse errorResponse = {message: "Component not found", 'error: "NOT_FOUND"};
            return errorResponse;
        }

        _ = asset.components.remove(componentId);
        serviceAssetDatabase[assetTag] = asset;
        
        ApiResponse response = {message: "Component removed successfully"};
        return response;
    }

    // SCHEDULE MANAGEMENT

    // Add maintenance schedule to asset
    resource function post assets/[string assetTag]/schedules(ScheduleRequest scheduleRequest) returns Response {
        if !serviceAssetDatabase.hasKey(assetTag) {
            ErrorResponse errorResponse = {message: "Asset not found", 'error: "NOT_FOUND"};
            return errorResponse;
        }

        Asset asset = serviceAssetDatabase.get(assetTag);
        string scheduleId = "SCH-" + generateId().substring(0, 8);
        
        MaintenanceSchedule newSchedule = {
            scheduleId: scheduleId,
            description: scheduleRequest.description,
            frequency: scheduleRequest.frequency,
            nextDueDate: scheduleRequest.nextDueDate
        };

        asset.schedules[scheduleId] = newSchedule;
        serviceAssetDatabase[assetTag] = asset;
        
        ApiResponse response = {
            message: "Schedule added successfully",
            data: newSchedule
        };
        return response;
    }

    // Remove maintenance schedule from asset
    resource function delete assets/[string assetTag]/schedules/[string scheduleId]() returns Response {
        if !serviceAssetDatabase.hasKey(assetTag) {
            ErrorResponse errorResponse = {message: "Asset not found", 'error: "NOT_FOUND"};
            return errorResponse;
        }

        Asset asset = serviceAssetDatabase.get(assetTag);
        if !asset.schedules.hasKey(scheduleId) {
            ErrorResponse errorResponse = {message: "Schedule not found", 'error: "NOT_FOUND"};
            return errorResponse;
        }

        _ = asset.schedules.remove(scheduleId);
        serviceAssetDatabase[assetTag] = asset;
        
        ApiResponse response = {message: "Schedule removed successfully"};
        return response;
    }

    // WORK ORDER MANAGEMENT

    // Create work order for asset
    resource function post assets/[string assetTag]/workorders(WorkOrderRequest workOrderRequest) returns Response {
        if !serviceAssetDatabase.hasKey(assetTag) {
            ErrorResponse errorResponse = {message: "Asset not found", 'error: "NOT_FOUND"};
            return errorResponse;
        }

        Asset asset = serviceAssetDatabase.get(assetTag);
        string workOrderId = "WO-" + generateId().substring(0, 8);
        
        WorkOrder newWorkOrder = {
            workOrderId: workOrderId,
            description: workOrderRequest.description,
            status: OPEN,
            createdDate: time:utcToString(time:utcNow()),
            assignedTechnician: workOrderRequest.assignedTechnician,
            tasks: {}
        };

        asset.workOrders[workOrderId] = newWorkOrder;
        serviceAssetDatabase[assetTag] = asset;
        
        ApiResponse response = {
            message: "Work order created successfully",
            data: newWorkOrder
        };
        return response;
    }

    // Update work order status
    resource function put assets/[string assetTag]/workorders/[string workOrderId]/status(map<string> statusUpdate) returns Response {
        if !serviceAssetDatabase.hasKey(assetTag) {
            ErrorResponse errorResponse = {message: "Asset not found", 'error: "NOT_FOUND"};
            return errorResponse;
        }

        Asset asset = serviceAssetDatabase.get(assetTag);
        if !asset.workOrders.hasKey(workOrderId) {
            ErrorResponse errorResponse = {message: "Work order not found", 'error: "NOT_FOUND"};
            return errorResponse;
        }

        WorkOrder workOrder = asset.workOrders.get(workOrderId);
        string? newStatus = statusUpdate["status"];
        
        if newStatus is string {
            // Parse status properly
            WorkOrderStatus status = OPEN; // Default
            if newStatus == "IN_PROGRESS" {
                status = IN_PROGRESS;
            } else if newStatus == "COMPLETED" {
                status = COMPLETED;
            } else if newStatus == "CLOSED" {
                status = CLOSED;
            }
            
            workOrder.status = status;
            if newStatus == "COMPLETED" || newStatus == "CLOSED" {
                workOrder.completedDate = time:utcToString(time:utcNow());
            }
        }

        asset.workOrders[workOrderId] = workOrder;
        serviceAssetDatabase[assetTag] = asset;
        
        ApiResponse response = {
            message: "Work order status updated successfully",
            data: workOrder
        };
        return response;
    }

    // TASK MANAGEMENT

    // Add task to work order
    resource function post assets/[string assetTag]/workorders/[string workOrderId]/tasks(TaskRequest taskRequest) returns Response {
        if !serviceAssetDatabase.hasKey(assetTag) {
            ErrorResponse errorResponse = {message: "Asset not found", 'error: "NOT_FOUND"};
            return errorResponse;
        }

        Asset asset = serviceAssetDatabase.get(assetTag);
        if !asset.workOrders.hasKey(workOrderId) {
            ErrorResponse errorResponse = {message: "Work order not found", 'error: "NOT_FOUND"};
            return errorResponse;
        }

        WorkOrder workOrder = asset.workOrders.get(workOrderId);
        string taskId = "TASK-" + generateId().substring(0, 8);
        
        Task newTask = {
            taskId: taskId,
            description: taskRequest.description,
            status: "pending",
            assignedTo: taskRequest.assignedTo
        };

        workOrder.tasks[taskId] = newTask;
        asset.workOrders[workOrderId] = workOrder;
        serviceAssetDatabase[assetTag] = asset;
        
        ApiResponse response = {
            message: "Task added successfully",
            data: newTask
        };
        return response;
    }

    // Remove task from work order
    resource function delete assets/[string assetTag]/workorders/[string workOrderId]/tasks/[string taskId]() returns Response {
        if !serviceAssetDatabase.hasKey(assetTag) {
            ErrorResponse errorResponse = {message: "Asset not found", 'error: "NOT_FOUND"};
            return errorResponse;
        }

        Asset asset = serviceAssetDatabase.get(assetTag);
        if !asset.workOrders.hasKey(workOrderId) {
            ErrorResponse errorResponse = {message: "Work order not found", 'error: "NOT_FOUND"};
            return errorResponse;
        }

        WorkOrder workOrder = asset.workOrders.get(workOrderId);
        if !workOrder.tasks.hasKey(taskId) {
            ErrorResponse errorResponse = {message: "Task not found", 'error: "NOT_FOUND"};
            return errorResponse;
        }

        _ = workOrder.tasks.remove(taskId);
        asset.workOrders[workOrderId] = workOrder;
        serviceAssetDatabase[assetTag] = asset;
        
        ApiResponse response = {message: "Task removed successfully"};
        return response;
    }
}
