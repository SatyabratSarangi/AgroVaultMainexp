-- AgroVault PostgreSQL Schema

-- Drop tables if they exist for clean initialization
DROP TABLE IF EXISTS reviews;
DROP TABLE IF EXISTS bookings;
DROP TABLE IF EXISTS storage_units;
DROP TABLE IF EXISTS users;

-- Users Table
-- Stores both farmers and storage owners
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('FARMER', 'OWNER')),
    city VARCHAR(100) NOT NULL
);

-- Storage Units Table
-- Managed by owners, booked by farmers
CREATE TABLE storage_units (
    id SERIAL PRIMARY KEY,
    owner_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    city VARCHAR(100) NOT NULL,
    capacity DECIMAL(10,2) NOT NULL, -- in metric tons
    price DECIMAL(10,2) NOT NULL, -- price per ton
    status VARCHAR(20) NOT NULL CHECK (status IN ('AVAILABLE', 'FULL')),
    image_url VARCHAR(500),
    description TEXT
);

-- Bookings Table (Updated for Financial Tracking)
-- Connects a farmer to a storage unit
CREATE TABLE bookings (
    id SERIAL PRIMARY KEY,
    farmer_id INTEGER NOT NULL REFERENCES users(id),
    unit_id INTEGER NOT NULL REFERENCES storage_units(id),
    product_name VARCHAR(200),
    booking_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    tons_booked DECIMAL(10,2) NOT NULL,
    base_amount DECIMAL(10,2),
    gst_amount DECIMAL(10,2),
    grand_total DECIMAL(10,2),
    status VARCHAR(20) NOT NULL CHECK (status IN ('PENDING', 'CONFIRMED', 'REJECTED'))
);

-- Reviews Table
-- Added for star ratings and comments
CREATE TABLE reviews (
    id SERIAL PRIMARY KEY,
    unit_id INTEGER NOT NULL REFERENCES storage_units(id) ON DELETE CASCADE,
    user_id INTEGER NOT NULL REFERENCES users(id),
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert Dummy Data for Testing
INSERT INTO users (name, email, password, role, city) VALUES 
('Rajesh Kumar', 'rajesh@farmer.com', 'password123', 'FARMER', 'Pune'),
('Amit Patel', 'amit@owner.com', 'password123', 'OWNER', 'Pune'),
('Suresh Singh', 'suresh@owner.com', 'password123', 'OWNER', 'Mumbai');

INSERT INTO storage_units (owner_id, title, city, capacity, price, status, image_url, description) VALUES
(2, 'Pune Cold Storage A', 'Pune', 500.00, 150.00, 'AVAILABLE', 'https://images.unsplash.com/photo-1587293852726-70cdb56c2866?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80', 'State of the art cold storage located near highway.'),
(2, 'AgriVault West', 'Pune', 200.00, 180.00, 'FULL', 'https://images.unsplash.com/photo-1542838132-92c53300491e?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80', 'Premium storage with advanced humidity control.'),
(3, 'Mumbai Central Cold Hub', 'Mumbai', 1000.00, 200.00, 'AVAILABLE', 'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80', 'Large capacity storage suitable for bulk produce.');

-- Insert Dummy Reviews
INSERT INTO reviews (unit_id, user_id, rating, comment) VALUES
(1, 1, 5, 'Great facility, kept my crops fresh!'),
(1, 1, 4, 'Very accessible location.'),
(2, 1, 3, 'A bit expensive but reliable.');
