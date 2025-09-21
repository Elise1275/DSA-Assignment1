import ballerina/grpc;
import ballerina/time;
import ballerina/uuid;
import ballerina/log;
import ballerina/lang.'string as strings;
import ballerina/regex;

listener grpc:Listener ep = new (9090);

// In-memory data storage
map<Car> cars = {};
map<User> users = {};
map<CartItem[]> userCarts = {};
map<ReservationDetails> reservations = {};

// Initialize sample data
function initializeSampleData() {
    // Create admin user
    User admin = {
        user_id: "admin1",
        username: "admin",
        email: "admin@carrental.com",
        phone: "+1-555-0001",
        role: ADMIN,
        full_name: "System Administrator",
        address: "123 Admin Street, City, State",
        license_number: "ADM123456",
        created_timestamp: time:utcNow()[0],
        is_active: true
    };
    users[admin.user_id] = admin;

    // Create sample customers
    User customer1 = {
        user_id: "cust1",
        username: "john_doe",
        email: "john.doe@email.com",
        phone: "+1-555-0002",
        role: CUSTOMER,
        full_name: "John Doe",
        address: "456 Customer Lane, City, State",
        license_number: "DL123456",
        created_timestamp: time:utcNow()[0],
        is_active: true
    };
    users[customer1.user_id] = customer1;
    userCarts[customer1.user_id] = [];

    User customer2 = {
        user_id: "cust2",
        username: "jane_smith",
        email: "jane.smith@email.com",
        phone: "+1-555-0003",
        role: CUSTOMER,
        full_name: "Jane Smith",
        address: "789 Customer Ave, City, State",
        license_number: "DL789012",
        created_timestamp: time:utcNow()[0],
        is_active: true
    };
    users[customer2.user_id] = customer2;
    userCarts[customer2.user_id] = [];

    // Create sample cars
    int currentTime = <int>time:utcNow()[0];
    Car car1 = {
        plate: "ABC123",
        make: "Toyota",
        model: "Camry",
        year: 2023,
        daily_price: 45.00,
        mileage: 15000,
        status: AVAILABLE,
        color: "Silver",
        fuel_type: "Gasoline",
        seating_capacity: 5,
        transmission: "Automatic",
        features: ["GPS Navigation", "Backup Camera", "Bluetooth"],
        location: "Downtown Branch",
        created_timestamp: currentTime,
        last_updated: currentTime
    };
    cars[car1.plate] = car1;

    Car car2 = {
        plate: "XYZ789",
        make: "Honda",
        model: "Civic",
        year: 2022,
        daily_price: 38.00,
        mileage: 22000,
        status: AVAILABLE,
        color: "Blue",
        fuel_type: "Gasoline",
        seating_capacity: 5,
        transmission: "Manual",
        features: ["Air Conditioning", "Power Windows"],
        location: "Airport Branch",
        created_timestamp: currentTime,
        last_updated: currentTime
    };
    cars[car2.plate] = car2;

    Car car3 = {
        plate: "LMN456",
        make: "Tesla",
        model: "Model 3",
        year: 2024,
        daily_price: 85.00,
        mileage: 5000,
        status: AVAILABLE,
        color: "White",
        fuel_type: "Electric",
        seating_capacity: 5,
        transmission: "Automatic",
        features: ["Autopilot", "Premium Interior", "Supercharging", "GPS Navigation"],
        location: "Downtown Branch",
        created_timestamp: currentTime,
        last_updated: currentTime
    };
    cars[car3.plate] = car3;

    log:printInfo("Sample data initialized successfully");
}

// Utility functions
function isValidUser(string userId, UserRole expectedRole) returns boolean {
    if !users.hasKey(userId) {
        return false;
    }
    User? user = users[userId];
    if user is User {
        return user.is_active && user.role == expectedRole;
    }
    return false;
}

function isValidDate(string dateStr) returns boolean {
    // Basic date validation for YYYY-MM-DD format
    return regex:matches(dateStr, "^\\d{4}-\\d{2}-\\d{2}$");
}

function calculateDays(string startDate, string endDate) returns int|error {
    if !isValidDate(startDate) || !isValidDate(endDate) {
        return error("Invalid date format. Use YYYY-MM-DD");
    }
    
    // Simple day calculation (for demonstration)
    // In production, use proper date parsing
    string[] startParts = regex:split(startDate, "-");
    string[] endParts = regex:split(endDate, "-");
    
    int startYear = check int:fromString(startParts[0]);
    int startMonth = check int:fromString(startParts[1]);
    int startDay = check int:fromString(startParts[2]);
    
    int endYear = check int:fromString(endParts[0]);
    int endMonth = check int:fromString(endParts[1]);
    int endDay = check int:fromString(endParts[2]);
    
    // Simple calculation - in reality would need proper date arithmetic
    int startDays = startYear * 365 + startMonth * 30 + startDay;
    int endDays = endYear * 365 + endMonth * 30 + endDay;
    
    int daysDiff = endDays - startDays;
    return daysDiff > 0 ? daysDiff : 0;
}

function isCarAvailable(string plate, string startDate, string endDate) returns boolean {
    // Check if car exists and is available
    if !cars.hasKey(plate) {
        return false;
    }
    
    Car? car = cars[plate];
    if car is () || car.status != AVAILABLE {
        return false;
    }
    
    // Check for conflicting reservations
    foreach ReservationDetails reservation in reservations {
        if reservation.plate == plate && reservation.status == CONFIRMED {
            // Check for date overlap (simplified logic)
            if !(endDate < reservation.start_date || startDate > reservation.end_date) {
                return false;
            }
        }
    }
    
    return true;
}

@grpc:Descriptor {value: CARRENTAL_DESC}
service "CarRentalService" on ep {

    function init() {
        initializeSampleData();
    }

    remote function AddCar(AddCarRequest value) returns AddCarResponse|error {
        log:printInfo("AddCar request received for plate: " + value.car.plate);
        
        // Validate admin user
        if !isValidUser(value.admin_user_id, ADMIN) {
            return {
                success: false,
                message: "Invalid admin user or insufficient permissions",
                car_id: ""
            };
        }
        
        // Check if car already exists
        if cars.hasKey(value.car.plate) {
            return {
                success: false,
                message: "Car with plate " + value.car.plate + " already exists",
                car_id: ""
            };
        }
        
        // Validate car data
        if value.car.plate == "" || value.car.make == "" || value.car.model == "" {
            return {
                success: false,
                message: "Required fields missing: plate, make, and model are mandatory",
                car_id: ""
            };
        }
        
        // Set timestamps
        Car newCar = value.car.clone();
        int currentTime = <int>time:utcNow()[0];
        newCar.created_timestamp = currentTime;
        newCar.last_updated = currentTime;
        
        // Add car to inventory
        cars[newCar.plate] = newCar;
        
        log:printInfo("Car added successfully: " + newCar.plate);
        return {
            success: true,
            message: "Car added successfully",
            car_id: newCar.plate
        };
    }

    remote function UpdateCar(UpdateCarRequest value) returns UpdateCarResponse|error {
        log:printInfo("UpdateCar request received for plate: " + value.plate);
        
        // Validate admin user
        if !isValidUser(value.admin_user_id, ADMIN) {
            return {
                success: false,
                message: "Invalid admin user or insufficient permissions",
                updated_car: {}
            };
        }
        
        // Check if car exists
        if !cars.hasKey(value.plate) {
            return {
                success: false,
                message: "Car with plate " + value.plate + " not found",
                updated_car: {}
            };
        }
        
        // Update car
        Car updatedCar = value.updated_car.clone();
        updatedCar.plate = value.plate; // Ensure plate remains the same
        updatedCar.last_updated = <int>time:utcNow()[0];
        Car? existingCar = cars[value.plate];
        if existingCar is Car {
            updatedCar.created_timestamp = existingCar.created_timestamp; // Preserve creation time
        }
        
        cars[value.plate] = updatedCar;
        
        log:printInfo("Car updated successfully: " + value.plate);
        return {
            success: true,
            message: "Car updated successfully",
            updated_car: updatedCar
        };
    }

    remote function RemoveCar(RemoveCarRequest value) returns RemoveCarResponse|error {
        log:printInfo("RemoveCar request received for plate: " + value.plate);
        
        // Validate admin user
        if !isValidUser(value.admin_user_id, ADMIN) {
            return {
                success: false,
                message: "Invalid admin user or insufficient permissions",
                remaining_cars: []
            };
        }
        
        // Check if car exists
        if !cars.hasKey(value.plate) {
            return {
                success: false,
                message: "Car with plate " + value.plate + " not found",
                remaining_cars: []
            };
        }
        
        // Check for active reservations
        foreach ReservationDetails reservation in reservations {
            if reservation.plate == value.plate && reservation.status == CONFIRMED {
                return {
                    success: false,
                    message: "Cannot remove car with active reservations",
                    remaining_cars: []
                };
            }
        }
        
        // Remove car
        _ = cars.remove(value.plate);
        
        // Return remaining cars
        Car[] remainingCars = cars.toArray();
        
        log:printInfo("Car removed successfully: " + value.plate);
        return {
            success: true,
            message: "Car removed successfully",
            remaining_cars: remainingCars
        };
    }

    remote function SearchCar(SearchCarRequest value) returns SearchCarResponse|error {
        log:printInfo("SearchCar request received for plate: " + value.plate);
        
        // Validate user
        if !users.hasKey(value.user_id) {
            return {
                found: false,
                available: false,
                car: {},
                message: "Invalid user",
                unavailable_dates: []
            };
        }
        
        // Check if car exists
        if !cars.hasKey(value.plate) {
            return {
                found: false,
                available: false,
                car: {},
                message: "Car not found",
                unavailable_dates: []
            };
        }
        
        Car? carNullable = cars[value.plate];
        if !(carNullable is Car) {
            return {
                found: false,
                available: false,
                car: {},
                message: "Car not found",
                unavailable_dates: []
            };
        }
        Car car = carNullable;
        boolean available = car.status == AVAILABLE;
        
        // Get unavailable dates
        string[] unavailableDates = [];
        foreach ReservationDetails reservation in reservations {
            if reservation.plate == value.plate && reservation.status == CONFIRMED {
                unavailableDates.push(reservation.start_date + " to " + reservation.end_date);
            }
        }
        
        return {
            found: true,
            available: available,
            car: car,
            message: available ? "Car is available" : "Car is not available",
            unavailable_dates: unavailableDates
        };
    }

    remote function AddToCart(AddToCartRequest value) returns AddToCartResponse|error {
        log:printInfo("AddToCart request received for user: " + value.user_id + ", car: " + value.plate);
        
        // Validate customer
        if !isValidUser(value.user_id, CUSTOMER) {
            return {
                success: false,
                message: "Invalid customer user",
                cart_item: {},
                cart_size: 0
            };
        }
        
        // Validate dates
        if !isValidDate(value.start_date) || !isValidDate(value.end_date) {
            return {
                success: false,
                message: "Invalid date format. Use YYYY-MM-DD",
                cart_item: {},
                cart_size: 0
            };
        }
        
        // Calculate rental days
        int rentalDays = check calculateDays(value.start_date, value.end_date);
        if rentalDays <= 0 {
            return {
                success: false,
                message: "End date must be after start date",
                cart_item: {},
                cart_size: 0
            };
        }
        
        // Check car availability
        if !isCarAvailable(value.plate, value.start_date, value.end_date) {
            return {
                success: false,
                message: "Car is not available for the selected dates",
                cart_item: {},
                cart_size: 0
            };
        }
        
        Car? carNullable = cars[value.plate];
        if !(carNullable is Car) {
            return {
                success: false,
                message: "Car not found",
                cart_item: {},
                cart_size: 0
            };
        }
        Car car = carNullable;
        float estimatedPrice = <float>rentalDays * car.daily_price;
        
        // Create cart item
        CartItem cartItem = {
            plate: value.plate,
            start_date: value.start_date,
            end_date: value.end_date,
            estimated_price: estimatedPrice,
            rental_days: rentalDays,
            added_timestamp: <int>time:utcNow()[0]
        };
        
        // Add to user's cart
        if !userCarts.hasKey(value.user_id) {
            userCarts[value.user_id] = [];
        }
        
        CartItem[]? cartNullable = userCarts[value.user_id];
        CartItem[] cart = cartNullable is CartItem[] ? cartNullable : [];
        cart.push(cartItem);
        userCarts[value.user_id] = cart;
        
        log:printInfo("Item added to cart for user: " + value.user_id);
        return {
            success: true,
            message: "Car added to cart successfully",
            cart_item: cartItem,
            cart_size: cart.length()
        };
    }

    remote function PlaceReservation(PlaceReservationRequest value) returns PlaceReservationResponse|error {
        log:printInfo("PlaceReservation request received for user: " + value.user_id);
        
        // Validate customer
        if !isValidUser(value.user_id, CUSTOMER) {
            return {
                success: false,
                message: "Invalid customer user",
                reservations: [],
                total_amount: 0.0,
                confirmation_number: ""
            };
        }
        
        // Check if cart exists and has items
        CartItem[]? cartNullable = userCarts[value.user_id];
        if !userCarts.hasKey(value.user_id) || !(cartNullable is CartItem[]) || cartNullable.length() == 0 {
            return {
                success: false,
                message: "Cart is empty",
                reservations: [],
                total_amount: 0.0,
                confirmation_number: ""
            };
        }
        
        CartItem[]? cartRef = userCarts[value.user_id];
        CartItem[] cart = cartRef is CartItem[] ? cartRef : [];
        ReservationDetails[] newReservations = [];
        float totalAmount = 0.0;
        
        // Validate all items in cart are still available
        foreach CartItem item in cart {
            if !isCarAvailable(item.plate, item.start_date, item.end_date) {
                return {
                    success: false,
                    message: "Car " + item.plate + " is no longer available for selected dates",
                    reservations: [],
                    total_amount: 0.0,
                    confirmation_number: ""
                };
            }
        }
        
        // Create reservations
        string confirmationNumber = uuid:createType4AsString();
        User? customerNullable = users[value.user_id];
        if !(customerNullable is User) {
            return {
                success: false,
                message: "User not found",
                reservations: [],
                total_amount: 0.0,
                confirmation_number: ""
            };
        }
        User customer = customerNullable;
        
        foreach CartItem item in cart {
            Car? carNullable = cars[item.plate];
            if !(carNullable is Car) {
                continue;
            }
            Car car = carNullable;
            string reservationId = uuid:createType4AsString();
            
            ReservationDetails reservation = {
                reservation_id: reservationId,
                user_id: value.user_id,
                plate: item.plate,
                start_date: item.start_date,
                end_date: item.end_date,
                total_price: item.estimated_price,
                rental_days: item.rental_days,
                status: CONFIRMED,
                created_timestamp: <int>time:utcNow()[0],
                last_updated: <int>time:utcNow()[0],
                customer_name: customer.full_name,
                customer_email: customer.email,
                car_details: car
            };
            
            reservations[reservationId] = reservation;
            newReservations.push(reservation);
            totalAmount = totalAmount + item.estimated_price;
            
            // Update car status to rented
            Car updatedCar = car.clone();
            updatedCar.status = RENTED;
            updatedCar.last_updated = <int>time:utcNow()[0];
            cars[item.plate] = updatedCar;
        }
        
        // Clear user's cart
        userCarts[value.user_id] = [];
        
        log:printInfo("Reservations created successfully for user: " + value.user_id);
        return {
            success: true,
            message: "Reservations placed successfully",
            reservations: newReservations,
            total_amount: totalAmount,
            confirmation_number: confirmationNumber
        };
    }

    remote function GetUserProfile(GetUserProfileRequest value) returns GetUserProfileResponse|error {
        log:printInfo("GetUserProfile request received for user: " + value.user_id);
        
        // Check if user exists
        if !users.hasKey(value.user_id) {
            return {
                success: false,
                user: {},
                message: "User not found",
                recent_reservations: []
            };
        }
        
        User? userNullable = users[value.user_id];
        if !(userNullable is User) {
            return {
                success: false,
                user: {},
                message: "User not found",
                recent_reservations: []
            };
        }
        User user = userNullable;
        
        // Get recent reservations for the user
        ReservationDetails[] recentReservations = [];
        foreach ReservationDetails reservation in reservations {
            if reservation.user_id == value.user_id {
                recentReservations.push(reservation);
            }
        }
        
        return {
            success: true,
            user: user,
            message: "User profile retrieved successfully",
            recent_reservations: recentReservations
        };
    }

    remote function ViewCart(ViewCartRequest value) returns ViewCartResponse|error {
        log:printInfo("ViewCart request received for user: " + value.user_id);
        
        // Validate user
        if !users.hasKey(value.user_id) {
            return {
                success: false,
                cart_items: [],
                total_estimated_price: 0.0,
                total_items: 0,
                message: "Invalid user"
            };
        }
        
        // Get user's cart
        CartItem[]? cartNullable = userCarts[value.user_id];
        CartItem[] cart = userCarts.hasKey(value.user_id) && cartNullable is CartItem[] ? cartNullable : [];
        
        float totalPrice = 0.0;
        foreach CartItem item in cart {
            totalPrice = totalPrice + item.estimated_price;
        }
        
        return {
            success: true,
            cart_items: cart,
            total_estimated_price: totalPrice,
            total_items: cart.length(),
            message: cart.length() == 0 ? "Cart is empty" : "Cart retrieved successfully"
        };
    }

    remote function CreateUsers(stream<CreateUserRequest, grpc:Error?> clientStream) returns CreateUsersResponse|error {
        log:printInfo("CreateUsers stream request received");
        
        int usersCreated = 0;
        string[] failedUserIds = [];
        
        // Process stream of users
        error? result = clientStream.forEach(function(CreateUserRequest req) {
            User user = req.user;
            
            // Validate user data
            if user.user_id == "" || user.username == "" || user.email == "" {
                failedUserIds.push(user.user_id);
                return;
            }
            
            // Check if user already exists
            if users.hasKey(user.user_id) {
                failedUserIds.push(user.user_id);
                return;
            }
            
            // Set timestamp and add user
            User newUser = user.clone();
            newUser.created_timestamp = <int>time:utcNow()[0];
            users[newUser.user_id] = newUser;
            
            // Initialize cart for customers
            if newUser.role == CUSTOMER {
                userCarts[newUser.user_id] = [];
            }
            
            usersCreated += 1;
        });
        
        if result is error {
            return result;
        }
        
        log:printInfo("Users created: " + usersCreated.toString());
        return {
            success: usersCreated > 0,
            message: usersCreated.toString() + " users created successfully",
            users_created: usersCreated,
            failed_user_ids: failedUserIds
        };
    }

    remote function ListAllReservations(ListReservationsRequest value) returns stream<ReservationDetails, error?>|error {
        log:printInfo("ListAllReservations request received");
        
        // Validate admin user
        if !isValidUser(value.admin_user_id, ADMIN) {
            return error("Invalid admin user or insufficient permissions");
        }
        
        ReservationDetails[] filteredReservations = [];
        
        foreach ReservationDetails reservation in reservations {
            boolean include = true;
            
            // Apply status filter
            if value.filter_status != "" {
                ReservationStatus filterStatus = value.filter_status == "CONFIRMED" ? CONFIRMED :
                                               value.filter_status == "PENDING" ? PENDING :
                                               value.filter_status == "COMPLETED" ? COMPLETED :
                                               value.filter_status == "CANCELLED" ? CANCELLED : PENDING;
                if reservation.status != filterStatus {
                    include = false;
                }
            }
            
            // Apply date filter (simplified - checks if reservation starts on the filtered date)
            if include && value.filter_date != "" {
                if reservation.start_date != value.filter_date {
                    include = false;
                }
            }
            
            if include {
                filteredReservations.push(reservation);
            }
        }
        
        // Convert to stream
        return filteredReservations.toStream();
    }

    remote function ListAvailableCars(ListAvailableCarsRequest value) returns stream<Car, error?>|error {
        log:printInfo("ListAvailableCars request received for user: " + value.user_id);
        
        // Validate user
        if !users.hasKey(value.user_id) {
            return error("Invalid user");
        }
        
        Car[] filteredCars = [];
        
        foreach Car car in cars {
            if car.status != AVAILABLE {
                continue;
            }
            
            boolean include = true;
            
            // Apply text filter (make, model, or features)
            if value.filter_text != "" {
                string filterText = value.filter_text.toLowerAscii();
                boolean textMatch = strings:includes(car.make.toLowerAscii(), filterText) ||
                                  strings:includes(car.model.toLowerAscii(), filterText) ||
                                  strings:includes(car.color.toLowerAscii(), filterText) ||
                                  strings:includes(car.fuel_type.toLowerAscii(), filterText);
                
                // Check features
                if !textMatch {
                    foreach string feature in car.features {
                        if strings:includes(feature.toLowerAscii(), filterText) {
                            textMatch = true;
                            break;
                        }
                    }
                }
                
                if !textMatch {
                    include = false;
                }
            }
            
            // Apply year filter
            if include && value.filter_year > 0 {
                if car.year != value.filter_year {
                    include = false;
                }
            }
            
            // Apply price filter
            if include && value.max_price > 0.0 {
                if car.daily_price > <float>value.max_price {
                    include = false;
                }
            }
            
            // Apply location filter
            if include && value.location != "" {
                if car.location != value.location {
                    include = false;
                }
            }
            
            if include {
                filteredCars.push(car);
            }
        }
        
        // Convert to stream
        return filteredCars.toStream();
    }
}
