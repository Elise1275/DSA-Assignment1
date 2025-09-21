// auth.bal - Authentication System
import ballerina/io;
import ballerina/crypto;

// User type definition
public type User record {
    string username;
    string passwordHash;
    string role;
    string fullName;
};

// Predefined users (in real application, this would be from database)
map<User> users = {
    "admin": {
        username: "admin",
        passwordHash: "8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918", // "admin" hashed
        role: "Administrator",
        fullName: "System Administrator"
    },
    "technician": {
        username: "technician",
        passwordHash: "5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8", // "password" hashed
        role: "Technician",
        fullName: "John Smith"
    },
    "manager": {
        username: "manager",
        passwordHash: "ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f", // "secret123" hashed
        role: "Manager",
        fullName: "Jane Doe"
    },
    "staff": {
        username: "staff",
        passwordHash: "6ca13d52ca70c883e0f0bb101e425a89e8624de51db2d2392593af6a84118090", // "nust2024" hashed
        role: "Staff",
        fullName: "Mary Johnson"
    }
};

// Current logged-in user
User? currentUser = ();

// Hash password using SHA-256
function hashPassword(string password) returns string {
    byte[] passwordBytes = password.toBytes();
    byte[] hashedBytes = crypto:hashSha256(passwordBytes);
    return hashedBytes.toBase16();
}

// Authenticate user
public function authenticateUser(string username, string password) returns boolean {
    if !users.hasKey(username) {
        return false;
    }
    
    User user = users.get(username);
    string hashedPassword = hashPassword(password);
    
    if user.passwordHash == hashedPassword {
        currentUser = user;
        return true;
    }
    
    return false;
}

// Get current user
public function getCurrentUser() returns User? {
    return currentUser;
}

// Check if user is logged in
public function isLoggedIn() returns boolean {
    return currentUser is User;
}

// Logout user
public function logout() {
    currentUser = ();
}

// Check user permissions
public function hasPermission(string operation) returns boolean {
    if currentUser is () {
        return false;
    }
    
    User? currentUserRef = currentUser;
    if currentUserRef is User {
        string role = currentUserRef.role;
        
        match operation {
        "CREATE_ASSET" => {
            return role == "Administrator" || role == "Manager" || role == "Staff";
        }
        "UPDATE_ASSET" => {
            return role == "Administrator" || role == "Manager" || role == "Technician";
        }
        "DELETE_ASSET" => {
            return role == "Administrator" || role == "Manager";
        }
        "VIEW_ASSETS" => {
            return true; // All logged-in users can view
        }
        "MANAGE_COMPONENTS" => {
            return role == "Administrator" || role == "Technician";
        }
        "MANAGE_SCHEDULES" => {
            return role == "Administrator" || role == "Manager" || role == "Technician";
        }
        "MANAGE_WORKORDERS" => {
            return role == "Administrator" || role == "Manager" || role == "Technician";
        }
        }
    }
    
    return false;
}

// Display available users (for demo purposes)
public function displayAvailableUsers() {
    io:println("\n=== Available Demo Users ===");
    io:println("Username: admin     | Password: admin     | Role: Administrator");
    io:println("Username: technician| Password: password  | Role: Technician"); 
    io:println("Username: manager   | Password: secret123 | Role: Manager");
    io:println("Username: staff     | Password: nust2024  | Role: Staff");
    io:println("===============================\n");
}

// Login prompt
public function promptLogin() returns boolean {
    io:println("\n╔════════════════════════════════════════╗");
    io:println("║         NUST Asset Management          ║");
    io:println("║              Login System              ║");
    io:println("╚════════════════════════════════════════╝");
    
    displayAvailableUsers();
    
    int attempts = 0;
    while attempts < 3 {
        io:print("Enter username: ");
        string username = (io:readln()).trim();
        
        if username == "" {
            io:println("Username cannot be empty!");
            attempts += 1;
            continue;
        }
        
        io:print("Enter password: ");
        string password = (io:readln()).trim();
        
        if password == "" {
            io:println("Password cannot be empty!");
            attempts += 1;
            continue;
        }
        
        if authenticateUser(username, password) {
            User? userRef = currentUser;
            if userRef is User {
                io:println("\n✅ Login successful!");
                io:println("Welcome, " + userRef.fullName + " (" + userRef.role + ")");
            }
            return true;
        } else {
            attempts += 1;
            io:println("❌ Invalid credentials! Attempts remaining: " + (3 - attempts).toString());
        }
    }
    
    io:println("\n❌ Maximum login attempts exceeded. Access denied.");
    return false;
}