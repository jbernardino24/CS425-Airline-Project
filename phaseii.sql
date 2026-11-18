CREATE TABLE Airport (
    iata_id CHAR(3) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    country VARCHAR(50) NOT NULL,
    state VARCHAR(50)
);

CREATE TABLE Airline (
    airline_code CHAR(2) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    country_origin VARCHAR(50) NOT NULL
);

CREATE TABLE Customer (
    email_address VARCHAR(255) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    home_airport CHAR(3),

    FOREIGN KEY (home_airport)
        REFERENCES Airport(iata_id)
);

/*Multivalued payment_address translation*/
CREATE TABLE Customer_Payment_Address (
    email_address VARCHAR(255) NOT NULL,
    payment_address VARCHAR(255) NOT NULL,

    PRIMARY KEY (email_address, payment_address),

    FOREIGN KEY (email_address)
        REFERENCES Customer(email_address)
);

CREATE TABLE Credit_Card (
    card_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    email_address VARCHAR(255) NOT NULL,
    payment_address VARCHAR(255) NOT NULL,

    FOREIGN KEY (email_address, payment_address)
        REFERENCES Customer_Payment_Address(email_address, payment_address)
);

CREATE TABLE Flight (
    airline_code CHAR(2) NOT NULL,
    flight_number INTEGER NOT NULL,
    flight_date DATE NOT NULL,

    departure_airport CHAR(3) NOT NULL,
    destination_airport CHAR(3) NOT NULL,

    departure_time TIMESTAMP NOT NULL,
    arrival_time TIMESTAMP NOT NULL,

    first_capacity INTEGER NOT NULL,
    economy_capacity INTEGER NOT NULL,

    economy_price DECIMAL(10,2) NOT NULL,
    first_price DECIMAL(10,2) NOT NULL,

    PRIMARY KEY (airline_code, flight_number, flight_date),

    FOREIGN KEY (airline_code)
        REFERENCES Airline(airline_code),

    FOREIGN KEY (departure_airport)
        REFERENCES Airport(iata_id),

    FOREIGN KEY (destination_airport)
        REFERENCES Airport(iata_id),

    CHECK (first_price > economy_price),
    CHECK (first_capacity >= 0),
    CHECK (economy_capacity >= 0),
    CHECK (economy_price >= 0),
    CHECK (first_price >= 0),
    CHECK (departure_airport <> destination_airport),
    CHECK (arrival_time > departure_time)
);

CREATE TABLE Booking (
    booking_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    email_address VARCHAR(255) NOT NULL,

    FOREIGN KEY (email_address)
        REFERENCES Customer(email_address)
);

CREATE TABLE BookingFlight (
    booking_id INTEGER NOT NULL,
    airline_code CHAR(2) NOT NULL,
    flight_number INTEGER NOT NULL,
    flight_date DATE NOT NULL,

    class VARCHAR(10) NOT NULL,
    card_id INTEGER NOT NULL,

    PRIMARY KEY (booking_id, airline_code, flight_number, flight_date),

    FOREIGN KEY (booking_id)
        REFERENCES Booking(booking_id),

    FOREIGN KEY (airline_code, flight_number, flight_date)
        REFERENCES Flight(airline_code, flight_number, flight_date),

    FOREIGN KEY (card_id)
        REFERENCES Credit_Card(card_id),

    CHECK (class IN ('Economy', 'First'))
);

/*Indices*/

/*for flight lookups using dep airport, dest airport, date*/
CREATE INDEX idx_flight_route_date ON Flight (departure_airport, destination_airport, flight_date);

/*for booking lookups using email address*/ 
CREATE INDEX idx_booking_email ON Booking(email_address);

/*for booking flight lookups concerning flight details*/
CREATE INDEX idx_bookingflight_flight_class ON BookingFlight (airline_code, flight_number, flight_date, class);

/*To evaluate*/
CREATE INDEX idx_credit_card_email ON Credit_Card(email_address);