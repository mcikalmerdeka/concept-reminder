"""
- MySQL Data Population Script for Airbnb-like Database
- This script generates synthetic data to populate a MySQL database with Airbnb-like data structures.
- It creates and populates three main tables: hosts, listings, and reviews in the specified database.
- The script uses the Faker library to generate realistic-looking fake data and mysql.connector to interact with MySQL database.
- Everytime the script is run, it will append new data with random values, including timestamps and price formats.

Tables Structure:
- hosts: Contains host information including superhost status
- listings: Contains property listings with references to hosts
- reviews: Contains reviews for listings with sentiment analysis

Features:
- Configurable number of hosts, listings per host, and reviews per listing
- Automatic database and table creation
- Referential integrity between tables using foreign keys
- Realistic data generation including timestamps and price formats
- Sentiment analysis classification for reviews

Dependencies:
    - mysql-connector-python: MySQL adapter for Python
    - faker: Library for generating fake data
    - random: For random selections
    - datetime: For timestamp handling
Database Configuration:
    - Define DB_NAME, DB_USER, DB_PASSWORD, and DB_HOST before running

Usage:
    Run the script directly to populate the database with default values:
    - 10 hosts
    - 3 listings per host
    - 5 reviews per listing
    
    Or import and call generate_data() with custom parameters:
    generate_data(num_hosts, num_listings_per_host, num_reviews_per_listing)

Source: Adapted from original PostgreSQL script by DeepSeek
"""

import mysql.connector
from faker import Faker
import random
from datetime import datetime, timedelta

# Database connection parameters
DB_NAME = "airbnb_experimental"
DB_USER = "root"
DB_PASSWORD = "cikalmerdeka"
DB_HOST = "localhost"

# Initialize Faker and random seed
fake = Faker()
random.seed(42)

# Function to create database
def create_database(cur):
    """Create database if it doesn't exist."""
    cur.execute(f"CREATE DATABASE IF NOT EXISTS {DB_NAME}")
    cur.execute(f"USE {DB_NAME}")

# Function to create tables
def create_tables(cur):
    """Create tables in the specified database."""
    
    # Create tables with InnoDB engine for foreign key support
    cur.execute("""
        CREATE TABLE IF NOT EXISTS hosts (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(255),
            host_is_superhost INTEGER,
            created_at TIMESTAMP,
            updated_at TIMESTAMP
        ) ENGINE=InnoDB
    """)
    cur.execute("""
        CREATE TABLE IF NOT EXISTS listings (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(255),
            room_type VARCHAR(50),
            minimum_nights INTEGER,
            host_id INTEGER,
            price VARCHAR(20),
            created_at TIMESTAMP,
            updated_at TIMESTAMP,
            FOREIGN KEY (host_id) REFERENCES hosts(id)
        ) ENGINE=InnoDB
    """)
    cur.execute("""
        CREATE TABLE IF NOT EXISTS reviews (
            id INT AUTO_INCREMENT PRIMARY KEY,
            listing_id INTEGER,
            reviewer_name VARCHAR(255),
            comments TEXT,
            sentiment VARCHAR(50),
            date TIMESTAMP,
            FOREIGN KEY (listing_id) REFERENCES listings(id)
        ) ENGINE=InnoDB
    """)

# Function to generate and insert synthetic data
def generate_data(num_hosts=10, num_listings_per_host=3, num_reviews_per_listing=5):
    """Generate and insert synthetic data."""
    
    # First connect to MySQL server to create database
    temp_conn = mysql.connector.connect(
        host=DB_HOST,
        user=DB_USER,
        password=DB_PASSWORD
    )
    temp_cur = temp_conn.cursor()
    create_database(temp_cur)
    temp_conn.commit()
    temp_cur.close()
    temp_conn.close()

    # Connect to target database
    conn = mysql.connector.connect(
        host=DB_HOST,
        user=DB_USER,
        password=DB_PASSWORD,
        database=DB_NAME
    )
    cur = conn.cursor()
    
    create_tables(cur)
    
    # Generate hosts
    host_ids = []
    for _ in range(num_hosts):

        # Create random data for each column
        name = fake.name()
        is_superhost = random.randint(0, 1)
        created_at = fake.date_time_this_decade()
        updated_at = fake.date_time_between(created_at, datetime.now())

        # Insert host
        cur.execute(
            """INSERT INTO hosts (name, host_is_superhost, created_at, updated_at)
               VALUES (%s, %s, %s, %s)""",
            (name, is_superhost, created_at, updated_at)
        )

        # Get the generated host ID
        host_id = cur.lastrowid
        host_ids.append(host_id)
    
    # Commit the transaction
    conn.commit()
    
    # Generate listings
    listing_ids = []
    for host_id in host_ids:
        for _ in range(num_listings_per_host):

            # Create random data for each column
            name = fake.sentence(nb_words=3).replace('.', '')
            room_type = random.choice(['Entire home', 'Private room', 'Shared room'])
            minimum_nights = random.randint(1, 30)
            price = f"${random.randint(50, 300)}.{random.randint(0, 99):02d}"
            created_at = fake.date_time_this_decade()
            updated_at = fake.date_time_between(created_at, datetime.now())
            
            # Insert listing
            cur.execute(
                """INSERT INTO listings (name, room_type, minimum_nights, host_id, price, created_at, updated_at)
                   VALUES (%s, %s, %s, %s, %s, %s, %s)""",
                (name, room_type, minimum_nights, host_id, price, created_at, updated_at)
            )

            # Get the generated listing ID
            listing_id = cur.lastrowid
            listing_ids.append(listing_id)

    # Commit the transaction
    conn.commit()
    
    # Generate reviews
    for listing_id in listing_ids:
        cur.execute("SELECT created_at FROM listings WHERE id = %s", (listing_id,))
        listing_created_at = cur.fetchone()[0]
        
        for _ in range(num_reviews_per_listing):

            # Create random data for each column
            reviewer_name = fake.name()
            comments = fake.text(max_nb_chars=200)
            sentiment = random.choice(['positive', 'neutral', 'negative'])
            date = fake.date_time_between(listing_created_at, datetime.now())

            # Insert review
            cur.execute(
                """INSERT INTO reviews (listing_id, reviewer_name, comments, sentiment, date)
                   VALUES (%s, %s, %s, %s, %s)""",
                (listing_id, reviewer_name, comments, sentiment, date)
            )
    # Commit the transaction
    conn.commit()
    
    # Close the connection
    cur.close()
    conn.close()

if __name__ == "__main__":
    generate_data()