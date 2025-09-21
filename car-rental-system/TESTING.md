# Testing Guide for Car Rental System

## Quick Start Testing

### 1. Start the Server
```bash
cd carrental_service
bal run
```
Expected output:
```
INFO [carrentalservice_service.bal:(123)] - Sample data initialized successfully
INFO [ballerina/grpc] - started HTTP/HTTPS/WS listener 0.0.0.0:9090
```

### 2. Start the Client
```bash
cd carrental_client
bal run
```

## Test Scenarios

### Admin User Testing (`admin1`)

#### Login Test
1. **Input**: `admin1`
2. **Expected**: Login successful, admin menu displayed

#### Car Management Tests

##### Add Car Test
1. Select option `1` (Add New Car)
2. **Sample Input**:
   - License Plate: `TEST001`
   - Make: `BMW`
   - Model: `X5`
   - Year: `2024`
   - Daily Price: `120.00`
   - Mileage: `0`
   - Color: `Black`
   - Fuel Type: `Gasoline`
   - Seating Capacity: `7`
   - Transmission: `Automatic`
   - Location: `Downtown Branch`
   - Features: `Premium Sound, Leather Seats, Sunroof`
3. **Expected**: ✓ Car added successfully! Car ID: TEST001

##### Update Car Test
1. Select option `2` (Update Car Details)
2. **Input**: License plate `ABC123`
3. **Update**: Change daily price to `50.00`
4. **Expected**: ✓ Car updated successfully!

##### Remove Car Test
1. Select option `3` (Remove Car)
2. **Input**: License plate `TEST001`
3. **Confirm**: Type `y`
4. **Expected**: ✓ Car removed successfully!

##### View Reservations Test
1. Select option `4` (View All Reservations)
2. **Filters**: Leave empty for all reservations
3. **Expected**: List of all reservations (initially empty)

##### Create Users Test (Streaming)
1. Select option `5` (Create Users)
2. **Sample User 1**:
   - User ID: `cust3`
   - Username: `mike_wilson`
   - Email: `mike@email.com`
   - Phone: `+1-555-0004`
   - Full Name: `Mike Wilson`
   - Address: `321 Test Street`
   - License Number: `DL345678`
   - Role: `1` (Customer)
3. **Continue**: `n` to finish
4. **Expected**: ✓ Users created successfully! Total users created: 1

### Customer User Testing (`cust1`)

#### Login Test
1. **Input**: `cust1`
2. **Expected**: Login successful, customer menu displayed

#### Car Discovery Tests

##### Browse Available Cars Test
1. Select option `1` (Browse Available Cars)
2. **Filters**: Leave all empty for all cars
3. **Expected**: List of 3 available cars (Toyota, Honda, Tesla)

##### Filter by Make Test
1. Select option `1` (Browse Available Cars)
2. **Filter text**: `Toyota`
3. **Expected**: Only Toyota Camry displayed

##### Filter by Price Test
1. Select option `1` (Browse Available Cars)
2. **Max price**: `50`
3. **Expected**: Toyota Camry ($45) and Honda Civic ($38) displayed

##### Search Car Test
1. Select option `2` (Search Specific Car)
2. **Input**: `ABC123`
3. **Expected**: Toyota Camry details with "Available for rental" status

#### Cart Operations Tests

##### Add to Cart Test
1. Select option `3` (Add Car to Cart)
2. **Sample Input**:
   - License Plate: `ABC123`
   - Start Date: `2024-12-25`
   - End Date: `2024-12-28`
3. **Expected**: ✓ Car added to cart successfully! Rental days: 3, Estimated price: $135.00

##### Invalid Date Test
1. Select option `3` (Add Car to Cart)
2. **Input**:
   - License Plate: `XYZ789`
   - Start Date: `2024/12/25` (wrong format)
   - End Date: `2024-12-28`
3. **Expected**: ✗ Invalid date format. Please use YYYY-MM-DD

##### View Cart Test
1. Select option `4` (View Cart)
2. **Expected**: Display cart items with total estimated price

##### Place Reservation Test
1. Ensure cart has items
2. Select option `5` (Place Reservation)
3. **Confirm**: `y`
4. **Payment Method**: `Credit Card`
5. **Special Requests**: `Pick up at 9 AM`
6. **Expected**: 🎉 Reservation placed successfully! with confirmation number

### Error Handling Tests

#### Invalid User Login
1. **Input**: `invalid_user`
2. **Expected**: "Invalid credentials. Please try again."

#### Unauthorized Operations
1. Login as customer (`cust1`)
2. Try to access admin-only operations (this would require modifying client to test)
3. **Expected**: Server should return "Invalid admin user or insufficient permissions"

#### Invalid Car Operations
1. **Search non-existent car**: License plate `INVALID`
2. **Expected**: "Car not found"

#### Date Validation Tests
1. **Invalid date format**: `25-12-2024`
2. **End before start**: Start: `2024-12-28`, End: `2024-12-25`
3. **Expected**: Appropriate error messages

#### Business Rule Tests
1. **Add duplicate car**: Try to add car with existing license plate
2. **Remove car with reservations**: Make reservation first, then try to remove that car
3. **Expected**: Business rule violation messages

## Profile and History Tests

### View Profile Test
1. Select option for "View Profile" (admin: 7, customer: 6)
2. **Expected**: Complete user information with recent reservations

### Reservation History Test
1. After making reservations, view profile
2. **Expected**: Recent reservations section shows booking history

## Load Testing Scenarios

### Streaming Operations Test
1. **Create Multiple Users**: Use streaming to add 5+ users
2. **Browse Large Dataset**: Filter through available cars
3. **Multiple Reservations**: Add multiple cars to cart and reserve

### Concurrent Operations Test
1. Run multiple client instances
2. Perform simultaneous operations
3. Verify data consistency

## Expected System Behavior

### Successful Operations
- Clear success messages with ✓ symbol
- Confirmation numbers for reservations
- Updated data reflected immediately
- Proper navigation between menus

### Error Conditions
- Clear error messages with ✗ symbol
- Graceful handling without crashes
- Helpful guidance for users
- Logging on server side

### Data Integrity
- Unique license plates enforced
- Date validation working
- Cart calculations correct
- Reservation conflicts prevented
- User authentication working

## Performance Expectations

### Response Times
- **Login**: Immediate (< 100ms)
- **Car Operations**: Fast (< 500ms)
- **Streaming**: Real-time processing
- **Cart/Reservation**: Quick (< 1s)

### Memory Usage
- **Server**: Stable memory usage
- **Client**: Minimal memory footprint
- **Data Storage**: Efficient in-memory structures

## Troubleshooting

### Common Issues

#### Server Won't Start
- Check if port 9090 is available
- Verify Ballerina installation
- Check generated protobuf files exist

#### Client Connection Errors
- Ensure server is running first
- Verify server address (localhost:9090)
- Check network connectivity

#### gRPC Generation Issues
- Verify proto file syntax
- Re-run `bal grpc` command
- Check file permissions

#### Invalid Operation Errors
- Verify user permissions (admin vs customer)
- Check input format (especially dates)
- Ensure required fields are provided

### Debug Commands
```bash
# Check Ballerina version
bal version

# Validate proto file
protoc --proto_path=protos --decode_raw < input.bin protos/carrental.proto

# Server logs
# Check console output for INFO/ERROR messages
```

## Advanced Testing

### Edge Cases
1. **Empty inputs**: Test with blank fields
2. **Large numbers**: Test with extreme values
3. **Special characters**: Test with Unicode/special chars
4. **Long strings**: Test field length limits

### Integration Testing
1. **End-to-end workflows**: Complete customer journey
2. **Admin workflows**: Full car lifecycle management
3. **Mixed operations**: Concurrent admin/customer actions

### Stress Testing
1. **Rapid operations**: Quick successive requests
2. **Large datasets**: Many cars/users/reservations
3. **Long sessions**: Extended usage patterns

## Test Data Cleanup

After testing, the server maintains state until restart. To reset:
1. Stop server (Ctrl+C)
2. Restart server
3. Fresh sample data will be loaded

## Validation Checklist

- [ ] All admin operations working
- [ ] All customer operations working
- [ ] Error handling functioning
- [ ] Date validation working
- [ ] Business rules enforced
- [ ] User authentication working
- [ ] Cart functionality complete
- [ ] Reservation process working
- [ ] Streaming operations functional
- [ ] Data integrity maintained
- [ ] Performance acceptable
- [ ] User experience smooth

## Reporting Issues

When reporting issues, include:
1. **Steps to reproduce**
2. **Expected behavior**
3. **Actual behavior**
4. **Error messages**
5. **System information**
6. **Log output**

This comprehensive testing approach ensures the Car Rental System meets all requirements and handles edge cases gracefully.