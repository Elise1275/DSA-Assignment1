# NUST Asset Management CLI Application - Complete Guide

## 🚀 How to Run the Application

```bash
cd C:\Users\Ismael\Documents\nust-asset-management\asset-management-system
bal run
```

## 🔐 Login Credentials

The application requires authentication. Use any of these predefined users:

| Username | Password | Role | Permissions |
|----------|----------|------|-------------|
| `admin` | `admin` | Administrator | Full access to all features |
| `manager` | `secret123` | Manager | Create/update/delete assets, manage schedules/work orders |
| `technician` | `password` | Technician | Update assets, manage components/schedules/work orders |
| `staff` | `nust2024` | Staff | Create/view assets, limited permissions |

## 🏗️ Application Structure

### Main Menu
After successful login, you'll see the main menu with these options:

1. **Asset Management** - CRUD operations for assets
2. **Component Management** - Add/remove asset components  
3. **Maintenance Scheduling** - Manage maintenance schedules
4. **Work Order Management** - Create and manage work orders
5. **Reports & Analytics** - Generate various reports
6. **System Information** - View system details and permissions
0. **Logout** - Exit the application

## 📋 Asset Management Features

### 1. View All Assets
- Displays assets in a formatted table
- Shows asset tag, name, faculty, and status
- Includes total count

### 2. Create New Asset
- **Required fields**: Name, Faculty, Department, Acquired Date
- **Status options**: ACTIVE, UNDER_REPAIR, DISPOSED
- **Auto-generates**: Unique asset tag (EQ-XXXXXXXX format)
- **Date format**: YYYY-MM-DD

### 3. Update Asset
- Select from existing assets
- Modify any field (press Enter to keep current value)
- Preserves existing components, schedules, and work orders

### 4. Delete Asset
- Confirmation required before deletion
- Removes all associated data (components, schedules, work orders)

### 5. Search Asset by Tag
- Find specific asset by exact tag match
- Shows detailed view with all components, schedules, and work orders

### 6. Filter Assets by Faculty
- Case-insensitive faculty name search
- Returns all assets belonging to specified faculty

### 7. View Overdue Maintenance
- Lists assets with overdue maintenance schedules
- Shows schedule details and due dates
- Automatically detects overdue based on current date

## 🔧 Component Management

### Add Component
- **Required**: Component name
- **Optional**: Description, serial number
- **Auto-generates**: Unique component ID (COMP-XXXXXXXX)

### Remove Component
- Select from existing components
- Confirmation required before removal

### View Components
- Detailed list of all components for an asset
- Shows ID, name, description, and serial number

## 📅 Maintenance Scheduling

### Add Schedule
- **Required**: Description, frequency, next due date
- **Frequency options**: Daily, Weekly, Monthly, Quarterly, Yearly, Custom
- **Date format**: YYYY-MM-DD
- **Auto-generates**: Unique schedule ID (SCH-XXXXXXXX)

### Remove Schedule
- Select from existing schedules
- Shows schedule details before confirmation

### View Schedules
- Lists all maintenance schedules for an asset
- **Status indicators**: ✅ On Schedule, ⚠️ OVERDUE
- Shows frequency and next due date

## 🛠️ Work Order Management

### Create Work Order
- **Required**: Description
- **Optional**: Assigned technician
- **Auto-generates**: Unique work order ID (WO-XXXXXXXX)
- **Default status**: OPEN
- **Auto-timestamps**: Creation date

### Update Status
- **Status options**: OPEN, IN_PROGRESS, COMPLETED, CLOSED
- **Auto-timestamps**: Completion date when marked COMPLETED/CLOSED

### Task Management (Future Enhancement)
- Add/remove tasks under work orders
- Task assignment and tracking

## 📊 Reports & Analytics

### 1. Asset Summary Report
- Total assets by status (Active, Under Repair, Disposed)
- Component, schedule, and work order counts
- Overdue maintenance statistics

### 2. Faculty-wise Distribution
- Asset count per faculty
- Helps identify resource allocation

### 3. Maintenance Status Report
- Total maintenance schedules
- On-time vs overdue percentages
- Detailed overdue schedule list

### 4. Work Order Status Report
- Work orders by status (Open, In Progress, Completed, Closed)
- Total counts and distribution

### 5. Assets by Status Report
- Detailed lists of assets grouped by status
- Shows asset tag, name, and faculty for each category

## 🔒 Permission System

### Administrator
- **Full access** to all features
- Can create, update, delete assets
- Manage all components, schedules, work orders
- View all reports

### Manager
- Create/update/delete assets
- Manage schedules and work orders
- View all reports
- Cannot manage components

### Technician
- Update assets (cannot create/delete)
- Manage components, schedules, work orders
- View assets and reports

### Staff
- Create and view assets
- View reports
- Limited management capabilities

## 🎯 Usage Tips

### Creating Your First Asset
1. Login with `admin` / `admin`
2. Select "1. Asset Management"
3. Select "2. Create New Asset"
4. Enter details:
   - Name: "Laptop Computer"
   - Faculty: "Computing & Informatics"
   - Department: "Software Engineering"
   - Status: Choose "1. ACTIVE"
   - Date: "2024-01-15"

### Adding Components
1. Go to "2. Component Management"
2. Select "1. Add Component to Asset"
3. Choose your asset
4. Add components like:
   - Name: "RAM Module"
   - Description: "16GB DDR4"
   - Serial: "RAM123456"

### Setting Up Maintenance
1. Go to "3. Maintenance Scheduling"
2. Select "1. Add Maintenance Schedule"
3. Add schedule:
   - Description: "Monthly system check"
   - Frequency: "3. Monthly"
   - Due Date: "2024-12-01"

### Testing Overdue Detection
1. Add a schedule with past due date (e.g., "2024-01-01")
2. Check "7. View Overdue Maintenance" in Asset Management
3. Or view "4. View All Overdue Maintenance" in Maintenance Scheduling

## 🚪 Exiting the Application
- Type "0" in any menu to go back
- Type "0" in main menu to logout
- Confirm logout when prompted
- Application will close gracefully

## 💡 Advanced Features

### Data Persistence
- All data is stored in memory during the session
- Data is lost when application closes
- For production use, integrate with a database

### Logging
- All user actions are logged with timestamps
- View logs for audit trails and debugging

### Role-based Access
- Different users see different menu options
- Operations are restricted based on user role
- Clear permission denied messages

### Date Validation
- Built-in date format validation (YYYY-MM-DD)
- Automatic overdue detection based on current date
- Proper handling of date parsing errors

This CLI application provides a complete asset management solution with an intuitive interface, comprehensive features, and robust security!