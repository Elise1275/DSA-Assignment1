# NUST Asset Management System

A RESTful API built with Ballerina 2201.12.9 for managing university assets, including laboratory equipment, servers, and vehicles.

## Features

- **Asset Management**: Create, read, update, and delete assets
- **Component Management**: Add/remove components for assets
- **Maintenance Scheduling**: Track maintenance schedules with overdue detection
- **Work Orders**: Manage repair and maintenance work orders
- **Task Management**: Track individual tasks within work orders
- **Faculty Filtering**: View assets by faculty
- **Overdue Detection**: Automatically identify assets with overdue maintenance

## Data Model

### Asset
```json
{
  "assetTag": "EQ-12345678",
  "name": "3D Printer",
  "faculty": "Computing & Informatics",
  "department": "Software Engineering",
  "status": "ACTIVE|UNDER_REPAIR|DISPOSED",
  "acquiredDate": "2024-03-10",
  "components": {},
  "schedules": {},
  "workOrders": {}
}
```

## API Endpoints

### Assets
- `GET /api/v1/assets` - Get all assets
- `POST /api/v1/assets` - Create new asset
- `GET /api/v1/assets/{assetTag}` - Get specific asset
- `PUT /api/v1/assets/{assetTag}` - Update asset
- `DELETE /api/v1/assets/{assetTag}` - Delete asset
- `GET /api/v1/assets/faculty/{faculty}` - Get assets by faculty
- `GET /api/v1/assets/overdue` - Get assets with overdue maintenance

### Components
- `POST /api/v1/assets/{assetTag}/components` - Add component to asset
- `DELETE /api/v1/assets/{assetTag}/components/{componentId}` - Remove component

### Maintenance Schedules
- `POST /api/v1/assets/{assetTag}/schedules` - Add maintenance schedule
- `DELETE /api/v1/assets/{assetTag}/schedules/{scheduleId}` - Remove schedule

### Work Orders
- `POST /api/v1/assets/{assetTag}/workorders` - Create work order
- `PUT /api/v1/assets/{assetTag}/workorders/{workOrderId}/status` - Update work order status

### Tasks
- `POST /api/v1/assets/{assetTag}/workorders/{workOrderId}/tasks` - Add task to work order
- `DELETE /api/v1/assets/{assetTag}/workorders/{workOrderId}/tasks/{taskId}` - Remove task

## Running the System

### Start the Service
```bash
cd asset-management-system
bal run
```

The service will start on port 8080 and be available at `http://localhost:8080/api/v1`

### Example Usage

#### Create an Asset
```bash
curl -X POST http://localhost:8080/api/v1/assets \
  -H "Content-Type: application/json" \
  -d '{
    "name": "3D Printer",
    "faculty": "Computing & Informatics", 
    "department": "Software Engineering",
    "status": "ACTIVE",
    "acquiredDate": "2024-03-10"
  }'
```

#### Get All Assets
```bash
curl -X GET http://localhost:8080/api/v1/assets
```

#### Add a Component
```bash
curl -X POST http://localhost:8080/api/v1/assets/EQ-12345678/components \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Print Head",
    "description": "High precision print head",
    "serialNumber": "PH-12345"
  }'
```

#### Add Maintenance Schedule
```bash
curl -X POST http://localhost:8080/api/v1/assets/EQ-12345678/schedules \
  -H "Content-Type: application/json" \
  -d '{
    "description": "Quarterly maintenance",
    "frequency": "quarterly",
    "nextDueDate": "2024-12-01"
  }'
```

#### Check Overdue Maintenance
```bash
curl -X GET http://localhost:8080/api/v1/assets/overdue
```

## Project Structure

- `types.bal` - Data type definitions
- `service.bal` - REST API service implementation
- `client.bal` - Demo client (test function)
- `main.bal` - Main entry point
- `Ballerina.toml` - Package configuration

## Requirements

- Ballerina 2201.12.9 (Swan Lake Update 12)
- Language specification 2024R1
- Tool version 1.5.1

## Implementation Notes

- In-memory storage using Ballerina maps
- Automatic ID generation for assets, components, schedules, work orders, and tasks
- Date-based overdue detection using UTC timestamps
- RESTful design following HTTP conventions
- Comprehensive error handling with proper HTTP status codes
- Type-safe implementation with Ballerina's type system

## Testing

The system has been tested with all major operations:
✅ Asset CRUD operations
✅ Faculty-based filtering  
✅ Component management
✅ Maintenance scheduling
✅ Overdue detection
✅ Work order management
✅ Task management

The client implementation in `client.bal` provides comprehensive examples of all API operations.