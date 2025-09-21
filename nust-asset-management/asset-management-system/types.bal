// types.bal

// Enums for asset status
public enum AssetStatus {
    ACTIVE,
    UNDER_REPAIR,
    DISPOSED
}

// Enums for work order status
public enum WorkOrderStatus {
    OPEN,
    IN_PROGRESS,
    COMPLETED,
    CLOSED
}

// Component record
public type Component record {
    string componentId;
    string name;
    string description?;
    string serialNumber?;
};

// Maintenance Schedule record
public type MaintenanceSchedule record {
    string scheduleId;
    string description;
    string frequency; // e.g., "quarterly", "yearly"
    string nextDueDate; // ISO date string
};

// Task record for work orders
public type Task record {
    string taskId;
    string description;
    string status; // "pending", "in_progress", "completed"
    string assignedTo?;
};

// Work Order record
public type WorkOrder record {
    string workOrderId;
    string description;
    WorkOrderStatus status;
    string createdDate;
    string completedDate?;
    string assignedTechnician?;
    map<Task> tasks;
};

// Main Asset record
public type Asset record {
    string assetTag;
    string name;
    string faculty;
    string department;
    AssetStatus status;
    string acquiredDate;
    map<Component> components;
    map<MaintenanceSchedule> schedules;
    map<WorkOrder> workOrders;
};

// Request/Response types
public type AssetRequest record {
    string name;
    string faculty;
    string department;
    string? status = "ACTIVE";
    string acquiredDate;
};

public type ComponentRequest record {
    string name;
    string description?;
    string serialNumber?;
};

public type ScheduleRequest record {
    string description;
    string frequency;
    string nextDueDate;
};

public type WorkOrderRequest record {
    string description;
    string? assignedTechnician = null;
};

public type TaskRequest record {
    string description;
    string? assignedTo = null;
};

// Response types
public type ApiResponse record {
    string message;
    anydata data?;
};

public type ErrorResponse record {
    string message;
    string 'error;
};

// Union type for responses
public type Response ApiResponse|ErrorResponse;
