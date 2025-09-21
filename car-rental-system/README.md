# Car Rental System - gRPC Implementation in Ballerina

## Overview

This is a comprehensive Car Rental System implemented using gRPC and Ballerina, supporting two user roles (Customer and Admin) with full CRUD operations for car management, reservations, and user cart functionality.

## Features

### Admin Operations
- **Add Car**: Register new vehicles in the system with detailed specifications
- **Update Car**: Modify car details, pricing, and availability status  
- **Remove Car**: Delete vehicles from inventory (with safety checks for active reservations)
- **View All Reservations**: Stream-based listing with filtering by status and date
- **Create Users (Batch)**: Stream multiple users to the system simultaneously
- **Search Car**: Look up vehicle details and availability
- **View User Profiles**: Access user information and reservation history

### Customer Operations
- **Browse Available Cars**: Stream-based listing with advanced filtering (make, model, year, price, location)
- **Search Specific Car**: Find vehicles by license plate with availability information
- **Add to Cart**: Select cars with rental dates and automatic price calculation
- **View Cart**: Review selected items with total pricing
- **Place Reservation**: Convert cart items to confirmed bookings
- **View Profile**: Access personal information and reservation history

## System Architecture

### Protocol Buffer Definition
The system uses a comprehensive protocol buffer schema (`protos/carrental.proto`) with:
- **Enums**: CarStatus, UserRole, ReservationStatus
- **Core Entities**: Car, User, CartItem, ReservationDetails
- **Request/Response Messages**: For all operations with proper validation fields
- **Streaming Support**: For bulk operations and large data sets

### Enhanced Features (Beyond Basic Requirements)
- **Advanced Car Details**: Color, fuel type, transmission, features array, location
- **User Management**: Complete user profiles with contact information and license details
- **Cart System**: Temporary storage with price calculation and date validation
- **Reservation Tracking**: Full lifecycle management with status updates
- **Filtering & Search**: Multi-criteria filtering for cars and reservations
- **Data Validation**: Input validation, date format checking, and business rule enforcement
- **Error Handling**: Comprehensive error messages and graceful failure handling

## Project Structure

```
car-rental-system/
├── protos/
│   └── carrental.proto              # Protocol Buffer definition
├── carrental_service/
│   ├── carrentalservice_service.bal # Server implementation
│   └── carrental_pb.bal            # Generated protobuf code
├── carrental_client/
│   ├── carrentalservice_client.bal  # Interactive client
│   └── carrental_pb.bal            # Generated protobuf code
└── car_rental/
    ├── Ballerina.toml              # Project configuration
    └── main.bal                    # Alternative entry point
```

## Prerequisites

- **Ballerina**: Version 2201.12.9 or later
- **Protocol Buffers**: For generating gRPC stubs
- **Java Runtime**: Required by Ballerina

## Installation & Setup

### 1. Install Ballerina
```bash
# Download from: https://ballerina.io/downloads/
# Follow installation instructions for your OS
```

### 2. Generate gRPC Code
```bash
# Generate server and client stubs from proto file
bal grpc --input protos/carrental.proto --output carrental_service --mode service
bal grpc --input protos/carrental.proto --output carrental_client --mode client
```

### 3. Build the Project
```bash
# Build server
cd carrental_service
bal build

# Build client
cd ../carrental_client
bal build
```

## Running the System

### Start the Server
```bash
cd carrental_service
bal run
```
The server will start on `localhost:9090` with sample data pre-loaded.

### Start the Client
```bash
cd carrental_client
bal run
```

## Default Sample Data

The system initializes with:

### Users
- **Admin**: `admin1` (System Administrator)
- **Customer 1**: `cust1` (John Doe)
- **Customer 2**: `cust2` (Jane Smith)

### Cars
- **Toyota Camry 2023** (ABC123) - $45/day
- **Honda Civic 2022** (XYZ789) - $38/day  
- **Tesla Model 3 2024** (LMN456) - $85/day

## Usage Examples

### Admin Workflow
1. **Login** as `admin1`
2. **Add New Car**: Register a new vehicle with full details
3. **Update Car**: Modify pricing or availability status
4. **View Reservations**: Monitor all bookings with filtering options
5. **Remove Car**: Delete vehicles (blocked if actively reserved)

### Customer Workflow  
1. **Login** as `cust1` or `cust2`
2. **Browse Cars**: Filter by make, year, price, or location
3. **Search Specific Car**: Check availability by license plate
4. **Add to Cart**: Select cars with rental dates
5. **Place Reservation**: Convert cart to confirmed booking
6. **View Profile**: Check reservation history

## API Operations

### Core gRPC Services

#### Unary Operations
- `AddCar(AddCarRequest) → AddCarResponse`
- `UpdateCar(UpdateCarRequest) → UpdateCarResponse`
- `RemoveCar(RemoveCarRequest) → RemoveCarResponse`
- `SearchCar(SearchCarRequest) → SearchCarResponse`
- `AddToCart(AddToCartRequest) → AddToCartResponse`
- `PlaceReservation(PlaceReservationRequest) → PlaceReservationResponse`
- `GetUserProfile(GetUserProfileRequest) → GetUserProfileResponse`
- `ViewCart(ViewCartRequest) → ViewCartResponse`

#### Streaming Operations
- `CreateUsers(stream CreateUserRequest) → CreateUsersResponse`
- `ListAllReservations(ListReservationsRequest) → stream ReservationDetails`
- `ListAvailableCars(ListAvailableCarsRequest) → stream Car`

## Business Rules

### Car Management
- License plates must be unique
- Only admins can add, update, or remove cars
- Cars with active reservations cannot be deleted
- Car status automatically updates when rented

### Reservation System
- Dates must be in YYYY-MM-DD format
- End date must be after start date
- Cars must be available for requested dates
- Price calculated as (days × daily_rate)
- Reservations check for date conflicts

### User Management
- User IDs must be unique
- Email validation for proper format
- License numbers required for customers
- Cart automatically initialized for customers

## Data Validation

### Input Validation
- Required field checking
- Date format validation (YYYY-MM-DD)
- Numeric field validation (year, price, mileage)
- Email format checking
- License plate format consistency

### Business Logic Validation
- User authentication and authorization
- Car availability checking
- Date conflict resolution
- Cart consistency validation
- Reservation integrity checks

## Error Handling

The system provides comprehensive error handling with:
- **Descriptive Messages**: Clear error descriptions for users
- **Graceful Failures**: Non-blocking error responses
- **Input Validation**: Pre-validation of all inputs
- **Business Rule Enforcement**: Automatic constraint checking
- **Logging**: Server-side operation logging

## Testing

### Manual Testing Scenarios

#### Admin Testing
1. **Car Management**: Add, update, remove cars
2. **Reservation Monitoring**: View and filter reservations
3. **User Creation**: Batch user creation via streaming
4. **Data Integrity**: Attempt invalid operations

#### Customer Testing  
1. **Car Discovery**: Browse and search functionality
2. **Cart Operations**: Add/remove items, view totals
3. **Reservation Process**: Complete booking workflow
4. **Profile Management**: View personal data and history

### Test Cases
- **Valid Operations**: All successful workflows
- **Invalid Inputs**: Date formats, missing fields, invalid IDs
- **Business Rules**: Duplicate plates, rental conflicts
- **Edge Cases**: Empty carts, non-existent cars, unauthorized access

## Performance Features

### Streaming Operations
- **Large Data Sets**: Efficient handling of multiple cars/reservations
- **Memory Optimization**: Stream-based processing for scalability
- **Real-time Processing**: Immediate response for batch operations

### Data Management
- **In-Memory Storage**: Fast access for demonstration
- **Indexed Access**: Hash-map based lookups
- **Concurrent Safety**: Thread-safe operations

## Future Enhancements

### Potential Improvements
- **Database Integration**: Replace in-memory storage
- **Authentication**: JWT-based security
- **Payment Processing**: Integration with payment gateways
- **Notification System**: Email/SMS confirmations
- **Geographic Services**: Location-based car finding
- **Mobile Apps**: Native mobile clients
- **Analytics Dashboard**: Usage statistics and reporting

### Scalability Considerations
- **Microservices**: Service decomposition
- **Load Balancing**: Multiple server instances
- **Caching**: Redis integration
- **Message Queues**: Asynchronous processing

## Technical Implementation Details

### Server Architecture
- **Service Layer**: Business logic implementation
- **Data Layer**: In-memory data management
- **Validation Layer**: Input and business rule validation
- **Utility Functions**: Date handling, string processing
- **Logging**: Operation tracking and debugging

### Client Architecture
- **Interactive Menus**: Role-based UI navigation
- **Input Validation**: Client-side data validation
- **Error Handling**: User-friendly error display
- **State Management**: Session and user context

## Contributing

To extend the system:
1. **Modify Protocol Buffer**: Update `carrental.proto` for new fields
2. **Regenerate Code**: Use `bal grpc` command
3. **Implement Logic**: Add business logic to server
4. **Update Client**: Add UI for new features
5. **Test Thoroughly**: Validate all scenarios

## License

This project is created for educational purposes as part of a distributed systems course assignment.

---

**Note**: This implementation demonstrates advanced gRPC concepts including streaming, comprehensive data modeling, and real-world business logic while maintaining clean, production-ready code structure.