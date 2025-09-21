import ballerina/io;
import ballerina/regex;

CarRentalServiceClient ep = check new ("http://localhost:9090");

// Current user context
string currentUserId = "";
string currentUserRole = "";

public function main() returns error? {
    io:println("\n=== Welcome to the Car Rental System ===");
    io:println("Please login to continue...");
    
    // Login process
    boolean loginSuccess = false;
    while !loginSuccess {
        loginSuccess = check performLogin();
        if !loginSuccess {
            io:println("\nInvalid credentials. Please try again.");
        }
    }
    
    io:println("\nLogin successful! Welcome, " + currentUserId);
    
    // Main application loop
    while true {
        if currentUserRole == "ADMIN" {
            check adminMenu();
        } else if currentUserRole == "CUSTOMER" {
            check customerMenu();
        } else {
            io:println("Unknown user role. Exiting...");
            break;
        }
        
        string continueChoice = io:readln("\nDo you want to continue? (y/n): ");
        if continueChoice.toLowerAscii() != "y" {
            break;
        }
    }
    
    io:println("\nThank you for using the Car Rental System. Goodbye!");
}

// Login functionality
function performLogin() returns boolean|error {
    io:println("\n--- Login ---");
    string userId = io:readln("Enter User ID: ").trim();
    
    if userId == "" {
        return false;
    }
    
    // Get user profile to validate
    GetUserProfileRequest profileRequest = {user_id: userId};
    GetUserProfileResponse profileResponse = check ep->GetUserProfile(profileRequest);
    
    if !profileResponse.success {
        return false;
    }
    
    currentUserId = userId;
    currentUserRole = profileResponse.user.role == ADMIN ? "ADMIN" : "CUSTOMER";
    return true;
}

// Admin Menu System
function adminMenu() returns error? {
    io:println("\n=== ADMIN MENU ===");
    io:println("1. Add New Car");
    io:println("2. Update Car Details");
    io:println("3. Remove Car");
    io:println("4. View All Reservations");
    io:println("5. Create Users (Batch)");
    io:println("6. Search Car");
    io:println("7. View User Profile");
    io:println("8. Logout");
    
    string choice = io:readln("\nSelect an option (1-8): ").trim();
    
    match choice {
        "1" => { check addCarOperation(); }
        "2" => { check updateCarOperation(); }
        "3" => { check removeCarOperation(); }
        "4" => { check listReservationsOperation(); }
        "5" => { check createUsersOperation(); }
        "6" => { check searchCarOperation(); }
        "7" => { check viewProfileOperation(); }
        "8" => { 
            currentUserId = "";
            currentUserRole = "";
            _ = check performLogin();
        }
        _ => { io:println("Invalid option. Please try again."); }
    }
}

// Customer Menu System
function customerMenu() returns error? {
    io:println("\n=== CUSTOMER MENU ===");
    io:println("1. Browse Available Cars");
    io:println("2. Search Specific Car");
    io:println("3. Add Car to Cart");
    io:println("4. View Cart");
    io:println("5. Place Reservation");
    io:println("6. View My Profile");
    io:println("7. Logout");
    
    string choice = io:readln("\nSelect an option (1-7): ").trim();
    
    match choice {
        "1" => { check browseAvailableCarsOperation(); }
        "2" => { check searchCarOperation(); }
        "3" => { check addToCartOperation(); }
        "4" => { check viewCartOperation(); }
        "5" => { check placeReservationOperation(); }
        "6" => { check viewProfileOperation(); }
        "7" => { 
            currentUserId = "";
            currentUserRole = "";
            _ = check performLogin();
        }
        _ => { io:println("Invalid option. Please try again."); }
    }
}

// Admin Operations
function addCarOperation() returns error? {
    io:println("\n--- Add New Car ---");
    
    string plate = io:readln("Enter License Plate: ").trim();
    string make = io:readln("Enter Make: ").trim();
    string model = io:readln("Enter Model: ").trim();
    
    string yearStr = io:readln("Enter Year: ").trim();
    int year = check int:fromString(yearStr);
    
    string priceStr = io:readln("Enter Daily Price: $").trim();
    float dailyPrice = check float:fromString(priceStr);
    
    string mileageStr = io:readln("Enter Mileage: ").trim();
    int mileage = check int:fromString(mileageStr);
    
    string color = io:readln("Enter Color: ").trim();
    string fuelType = io:readln("Enter Fuel Type (Gasoline/Electric/Hybrid): ").trim();
    
    string capacityStr = io:readln("Enter Seating Capacity: ").trim();
    int capacity = check int:fromString(capacityStr);
    
    string transmission = io:readln("Enter Transmission (Manual/Automatic): ").trim();
    string location = io:readln("Enter Location: ").trim();
    
    string featuresStr = io:readln("Enter Features (comma-separated): ").trim();
    string[] features = featuresStr != "" ? regex:split(featuresStr, ",") : [];
    
    // Clean up features array
    foreach int i in 0 ..< features.length() {
        features[i] = features[i].trim();
    }
    
    Car newCar = {
        plate: plate,
        make: make,
        model: model,
        year: year,
        daily_price: dailyPrice,
        mileage: mileage,
        status: AVAILABLE,
        color: color,
        fuel_type: fuelType,
        seating_capacity: capacity,
        transmission: transmission,
        features: features,
        location: location,
        created_timestamp: 0, // Will be set by server
        last_updated: 0 // Will be set by server
    };
    
    AddCarRequest request = {admin_user_id: currentUserId, car: newCar};
    AddCarResponse response = check ep->AddCar(request);
    
    if response.success {
        io:println("\n✓ Car added successfully!");
        io:println("Car ID: " + response.car_id);
    } else {
        io:println("\n✗ Failed to add car: " + response.message);
    }
}

function updateCarOperation() returns error? {
    io:println("\n--- Update Car ---");
    
    string plate = io:readln("Enter License Plate of car to update: ").trim();
    
    // First, get current car details
    SearchCarRequest searchRequest = {user_id: currentUserId, plate: plate};
    SearchCarResponse searchResponse = check ep->SearchCar(searchRequest);
    
    if !searchResponse.found {
        io:println("Car not found!");
        return;
    }
    
    Car currentCar = searchResponse.car;
    io:println("\nCurrent car details:");
    printCarDetails(currentCar);
    
    io:println("\nEnter new values (press Enter to keep current value):");
    
    string make = getInputOrDefault("Make", currentCar.make);
    string model = getInputOrDefault("Model", currentCar.model);
    
    string yearStr = getInputOrDefault("Year", currentCar.year.toString());
    int year = check int:fromString(yearStr);
    
    string priceStr = getInputOrDefault("Daily Price", currentCar.daily_price.toString());
    float dailyPrice = check float:fromString(priceStr);
    
    string mileageStr = getInputOrDefault("Mileage", currentCar.mileage.toString());
    int mileage = check int:fromString(mileageStr);
    
    string color = getInputOrDefault("Color", currentCar.color);
    string fuelType = getInputOrDefault("Fuel Type", currentCar.fuel_type);
    
    string capacityStr = getInputOrDefault("Seating Capacity", currentCar.seating_capacity.toString());
    int capacity = check int:fromString(capacityStr);
    
    string transmission = getInputOrDefault("Transmission", currentCar.transmission);
    string location = getInputOrDefault("Location", currentCar.location);
    
    io:println("\nSelect car status:");
    io:println("1. Available");
    io:println("2. Unavailable");
    io:println("3. Under Maintenance");
    io:println("4. Rented");
    
    string statusChoice = io:readln("Enter choice (1-4): ").trim();
    CarStatus status = statusChoice == "1" ? AVAILABLE :
                      statusChoice == "2" ? UNAVAILABLE :
                      statusChoice == "3" ? UNDER_MAINTENANCE :
                      statusChoice == "4" ? RENTED : AVAILABLE;
    
    Car updatedCar = {
        plate: plate,
        make: make,
        model: model,
        year: year,
        daily_price: dailyPrice,
        mileage: mileage,
        status: status,
        color: color,
        fuel_type: fuelType,
        seating_capacity: capacity,
        transmission: transmission,
        features: currentCar.features, // Keep existing features
        location: location,
        created_timestamp: currentCar.created_timestamp,
        last_updated: 0 // Will be updated by server
    };
    
    UpdateCarRequest request = {admin_user_id: currentUserId, plate: plate, updated_car: updatedCar};
    UpdateCarResponse response = check ep->UpdateCar(request);
    
    if response.success {
        io:println("\n✓ Car updated successfully!");
    } else {
        io:println("\n✗ Failed to update car: " + response.message);
    }
}

function removeCarOperation() returns error? {
    io:println("\n--- Remove Car ---");
    
    string plate = io:readln("Enter License Plate of car to remove: ").trim();
    
    string confirm = io:readln("Are you sure you want to remove car " + plate + "? (y/N): ").trim();
    if confirm.toLowerAscii() != "y" {
        io:println("Operation cancelled.");
        return;
    }
    
    RemoveCarRequest request = {admin_user_id: currentUserId, plate: plate};
    RemoveCarResponse response = check ep->RemoveCar(request);
    
    if response.success {
        io:println("\n✓ Car removed successfully!");
        io:println("Remaining cars in inventory: " + response.remaining_cars.length().toString());
    } else {
        io:println("\n✗ Failed to remove car: " + response.message);
    }
}

function listReservationsOperation() returns error? {
    io:println("\n--- All Reservations ---");
    
    string statusFilter = io:readln("Filter by status (PENDING/CONFIRMED/COMPLETED/CANCELLED) or press Enter for all: ").trim();
    string dateFilter = io:readln("Filter by start date (YYYY-MM-DD) or press Enter for all: ").trim();
    
    ListReservationsRequest request = {
        admin_user_id: currentUserId,
        filter_status: statusFilter,
        filter_date: dateFilter
    };
    
    stream<ReservationDetails, error?> reservationStream = check ep->ListAllReservations(request);
    
    int count = 0;
    check reservationStream.forEach(function(ReservationDetails reservation) {
        count += 1;
        io:println("\n--- Reservation #" + count.toString() + " ---");
        printReservationDetails(reservation);
    });
    
    if count == 0 {
        io:println("No reservations found matching the criteria.");
    } else {
        io:println("\nTotal reservations: " + count.toString());
    }
}

function createUsersOperation() returns error? {
    io:println("\n--- Create Users (Batch) ---");
    
    CreateUsersStreamingClient streamingClient = check ep->CreateUsers();
    
    while true {
        io:println("\n--- Enter User Details ---");
        string userId = io:readln("User ID: ").trim();
        if userId == "" {
            break;
        }
        
        string username = io:readln("Username: ").trim();
        string email = io:readln("Email: ").trim();
        string phone = io:readln("Phone: ").trim();
        string fullName = io:readln("Full Name: ").trim();
        string address = io:readln("Address: ").trim();
        string licenseNumber = io:readln("License Number: ").trim();
        
        io:println("\nSelect role:");
        io:println("1. Customer");
        io:println("2. Admin");
        string roleChoice = io:readln("Enter choice (1-2): ").trim();
        UserRole role = roleChoice == "2" ? ADMIN : CUSTOMER;
        
        User newUser = {
            user_id: userId,
            username: username,
            email: email,
            phone: phone,
            role: role,
            full_name: fullName,
            address: address,
            license_number: licenseNumber,
            created_timestamp: 0, // Will be set by server
            is_active: true
        };
        
        CreateUserRequest userRequest = {user: newUser};
        check streamingClient->sendCreateUserRequest(userRequest);
        
        string continueInput = io:readln("\nAdd another user? (y/N): ").trim();
        if continueInput.toLowerAscii() != "y" {
            break;
        }
    }
    
    check streamingClient->complete();
    CreateUsersResponse? response = check streamingClient->receiveCreateUsersResponse();
    
    if response is CreateUsersResponse {
        if response.success {
            io:println("\n✓ Users created successfully!");
            io:println("Total users created: " + response.users_created.toString());
        } else {
            io:println("\n✗ Failed to create users: " + response.message);
        }
        
        if response.failed_user_ids.length() > 0 {
            io:println("Failed user IDs: " + response.failed_user_ids.toString());
        }
    }
}

// Customer Operations
function browseAvailableCarsOperation() returns error? {
    io:println("\n--- Browse Available Cars ---");
    
    string filterText = io:readln("Filter by text (make/model/color/fuel type) or press Enter for all: ").trim();
    string yearStr = io:readln("Filter by year or press Enter for all: ").trim();
    int filterYear = yearStr != "" ? check int:fromString(yearStr) : 0;
    string priceStr = io:readln("Maximum daily price or press Enter for all: ").trim();
    float maxPrice = priceStr != "" ? check float:fromString(priceStr) : 0.0;
    string location = io:readln("Filter by location or press Enter for all: ").trim();
    
    ListAvailableCarsRequest request = {
        user_id: currentUserId,
        filter_text: filterText,
        filter_year: filterYear,
        max_price: maxPrice,
        location: location
    };
    
    stream<Car, error?> carStream = check ep->ListAvailableCars(request);
    
    int count = 0;
    check carStream.forEach(function(Car car) {
        count += 1;
        io:println("\n--- Car #" + count.toString() + " ---");
        printCarDetails(car);
    });
    
    if count == 0 {
        io:println("No cars found matching your criteria.");
    } else {
        io:println("\nTotal cars found: " + count.toString());
    }
}

function searchCarOperation() returns error? {
    io:println("\n--- Search Car ---");
    
    string plate = io:readln("Enter License Plate: ").trim();
    
    SearchCarRequest request = {user_id: currentUserId, plate: plate};
    SearchCarResponse response = check ep->SearchCar(request);
    
    if response.found {
        io:println("\n✓ Car found!");
        printCarDetails(response.car);
        
        if response.available {
            io:println("\n🟢 Status: Available for rental");
        } else {
            io:println("\n🔴 Status: " + response.message);
            if response.unavailable_dates.length() > 0 {
                io:println("Unavailable dates: ");
                foreach string dateRange in response.unavailable_dates {
                    io:println("  - " + dateRange);
                }
            }
        }
    } else {
        io:println("\n✗ " + response.message);
    }
}

function addToCartOperation() returns error? {
    io:println("\n--- Add Car to Cart ---");
    
    string plate = io:readln("Enter License Plate: ").trim();
    string startDate = io:readln("Enter Start Date (YYYY-MM-DD): ").trim();
    string endDate = io:readln("Enter End Date (YYYY-MM-DD): ").trim();
    
    // Validate date format
    if !regex:matches(startDate, "^\\d{4}-\\d{2}-\\d{2}$") || 
       !regex:matches(endDate, "^\\d{4}-\\d{2}-\\d{2}$") {
        io:println("\n✗ Invalid date format. Please use YYYY-MM-DD");
        return;
    }
    
    AddToCartRequest request = {
        user_id: currentUserId,
        plate: plate,
        start_date: startDate,
        end_date: endDate
    };
    
    AddToCartResponse response = check ep->AddToCart(request);
    
    if response.success {
        io:println("\n✓ Car added to cart successfully!");
        io:println("Rental days: " + response.cart_item.rental_days.toString());
        io:println("Estimated price: $" + response.cart_item.estimated_price.toString());
        io:println("Total items in cart: " + response.cart_size.toString());
    } else {
        io:println("\n✗ Failed to add car to cart: " + response.message);
    }
}

function viewCartOperation() returns error? {
    io:println("\n--- Your Cart ---");
    
    ViewCartRequest request = {user_id: currentUserId};
    ViewCartResponse response = check ep->ViewCart(request);
    
    if response.success && response.total_items > 0 {
        foreach int i in 0 ..< response.cart_items.length() {
            CartItem item = response.cart_items[i];
            io:println("\n--- Item #" + (i + 1).toString() + " ---");
            io:println("License Plate: " + item.plate);
            io:println("Rental Period: " + item.start_date + " to " + item.end_date);
            io:println("Rental Days: " + item.rental_days.toString());
            io:println("Estimated Price: $" + item.estimated_price.toString());
        }
        
        io:println("\n--- Cart Summary ---");
        io:println("Total Items: " + response.total_items.toString());
        io:println("Total Estimated Price: $" + response.total_estimated_price.toString());
    } else {
        io:println(response.message);
    }
}

function placeReservationOperation() returns error? {
    io:println("\n--- Place Reservation ---");
    
    // First, show current cart
    check viewCartOperation();
    
    string confirm = io:readln("\nProceed with reservation? (y/N): ").trim();
    if confirm.toLowerAscii() != "y" {
        io:println("Reservation cancelled.");
        return;
    }
    
    string paymentMethod = io:readln("Payment Method (Credit Card/Debit Card/PayPal): ").trim();
    string specialRequests = io:readln("Special Requests (optional): ").trim();
    
    PlaceReservationRequest request = {
        user_id: currentUserId,
        payment_method: paymentMethod,
        special_requests: specialRequests
    };
    
    PlaceReservationResponse response = check ep->PlaceReservation(request);
    
    if response.success {
        io:println("\n🎉 Reservation placed successfully!");
        io:println("Confirmation Number: " + response.confirmation_number);
        io:println("Total Amount: $" + response.total_amount.toString());
        io:println("Number of reservations: " + response.reservations.length().toString());
        
        foreach int i in 0 ..< response.reservations.length() {
            ReservationDetails reservation = response.reservations[i];
            io:println("\n--- Reservation #" + (i + 1).toString() + " ---");
            io:println("Reservation ID: " + reservation.reservation_id);
            io:println("Car: " + reservation.car_details.make + " " + reservation.car_details.model + " (" + reservation.plate + ")");
            io:println("Period: " + reservation.start_date + " to " + reservation.end_date);
            io:println("Price: $" + reservation.total_price.toString());
        }
    } else {
        io:println("\n✗ Failed to place reservation: " + response.message);
    }
}

function viewProfileOperation() returns error? {
    io:println("\n--- User Profile ---");
    
    GetUserProfileRequest request = {user_id: currentUserId};
    GetUserProfileResponse response = check ep->GetUserProfile(request);
    
    if response.success {
        User user = response.user;
        io:println("\n--- Personal Information ---");
        io:println("User ID: " + user.user_id);
        io:println("Full Name: " + user.full_name);
        io:println("Username: " + user.username);
        io:println("Email: " + user.email);
        io:println("Phone: " + user.phone);
        io:println("Address: " + user.address);
        io:println("License Number: " + user.license_number);
        io:println("Role: " + (user.role == ADMIN ? "Administrator" : "Customer"));
        io:println("Account Status: " + (user.is_active ? "Active" : "Inactive"));
        
        if response.recent_reservations.length() > 0 {
            io:println("\n--- Recent Reservations ---");
            foreach int i in 0 ..< response.recent_reservations.length() {
                ReservationDetails reservation = response.recent_reservations[i];
                io:println("\n" + (i + 1).toString() + ". " + reservation.car_details.make + " " + reservation.car_details.model + " (" + reservation.plate + ")");
                io:println("   Period: " + reservation.start_date + " to " + reservation.end_date);
                io:println("   Status: " + getReservationStatusString(reservation.status));
                io:println("   Total: $" + reservation.total_price.toString());
            }
        }
    } else {
        io:println("\n✗ Failed to retrieve profile: " + response.message);
    }
}

// Utility functions
function getInputOrDefault(string fieldName, string defaultValue) returns string {
    string input = io:readln(fieldName + " [" + defaultValue + "]: ").trim();
    return input != "" ? input : defaultValue;
}

function printCarDetails(Car car) {
    io:println("License Plate: " + car.plate);
    io:println("Make/Model: " + car.make + " " + car.model);
    io:println("Year: " + car.year.toString());
    io:println("Daily Price: $" + car.daily_price.toString());
    io:println("Mileage: " + car.mileage.toString() + " miles");
    io:println("Color: " + car.color);
    io:println("Fuel Type: " + car.fuel_type);
    io:println("Seating: " + car.seating_capacity.toString() + " passengers");
    io:println("Transmission: " + car.transmission);
    io:println("Location: " + car.location);
    io:println("Status: " + getCarStatusString(car.status));
    if car.features.length() > 0 {
        io:println("Features: " + car.features.toString());
    }
}

function printReservationDetails(ReservationDetails reservation) {
    io:println("Reservation ID: " + reservation.reservation_id);
    io:println("Customer: " + reservation.customer_name + " (" + reservation.customer_email + ")");
    io:println("Car: " + reservation.car_details.make + " " + reservation.car_details.model + " (" + reservation.plate + ")");
    io:println("Period: " + reservation.start_date + " to " + reservation.end_date + " (" + reservation.rental_days.toString() + " days)");
    io:println("Status: " + getReservationStatusString(reservation.status));
    io:println("Total Price: $" + reservation.total_price.toString());
}

function getCarStatusString(CarStatus status) returns string {
    match status {
        AVAILABLE => { return "Available"; }
        UNAVAILABLE => { return "Unavailable"; }
        UNDER_MAINTENANCE => { return "Under Maintenance"; }
        RENTED => { return "Currently Rented"; }
    }
    return "Unknown";
}

function getReservationStatusString(ReservationStatus status) returns string {
    match status {
        PENDING => { return "Pending"; }
        CONFIRMED => { return "Confirmed"; }
        COMPLETED => { return "Completed"; }
        CANCELLED => { return "Cancelled"; }
    }
    return "Unknown";
}
