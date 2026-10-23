"""
- PostgreSQL Data Population Script for Airbnb-like Database
- This script generates synthetic data to populate a PostgreSQL database with Airbnb-like data structures.
= It creates and populates three main tables: hosts, listings, and reviews in a specified schema.
- The script uses the Faker library to generate realistic-looking fake data and psycopg2 to interact with PostgreSQL database.
- Everytime the script is run, it will append new data with random values, including timestamps and price formats.

Tables Structure:
- hosts: Contains host information including superhost status
- listings: Contains property listings with references to hosts
- reviews: Contains reviews for listings with sentiment analysis

Features:
- Configurable number of hosts, listings per host, and reviews per listing
- Automatic schema creation
- Referential integrity between tables
- Realistic data generation including timestamps and price formats
- Sentiment analysis classification for reviews

Dependencies:
    - psycopg2: PostgreSQL adapter for Python
    - faker: Library for generating fake data
    - random: For random selections
    - datetime: For timestamp handling
Database Configuration:
    - Define DB_NAME, DB_USER, DB_PASSWORD, DB_HOST, and SCHEMA_NAME before running

Usage:
    Run the script directly to populate the database with default values:
    - 10 hosts
    - 3 listings per host
    - 5 reviews per listing
    
    Or import and call generate_data() with custom parameters:
    generate_data(num_hosts, num_listings_per_host, num_reviews_per_listing)

Source: https://chat.deepseek.com/a/chat/s/5379ce63-f647-4a20-9af4-9f51768c7d3c

"""

import psycopg2
from faker import Faker
import random
from datetime import datetime, timedelta

# Database connection parameters
DB_NAME = "airbnb_experimental"
DB_USER = "postgres"
DB_PASSWORD = "cikalmerdeka"
DB_HOST = "localhost"
SCHEMA_NAME = "raw"  # <-- Specify your schema name here

# Initialize Faker and random seed
fake = Faker()
random.seed(42)

# Function to create tables
def create_tables(cur):
    """Create tables in the specified schema."""

    # Create schema if it doesn't exist
    cur.execute(f"CREATE SCHEMA IF NOT EXISTS {SCHEMA_NAME}")  # Optional
    
    # Create tables with schema prefix
    cur.execute(f"""
        CREATE TABLE IF NOT EXISTS {SCHEMA_NAME}.hosts (
            id SERIAL PRIMARY KEY,
            name VARCHAR(255),
            host_is_superhost INTEGER,
            created_at TIMESTAMP,
            updated_at TIMESTAMP
        )
    """)
    cur.execute(f"""
        CREATE TABLE IF NOT EXISTS {SCHEMA_NAME}.listings (
            id SERIAL PRIMARY KEY,
            name VARCHAR(255),
            room_type VARCHAR(50),
            minimum_nights INTEGER,
            host_id INTEGER REFERENCES {SCHEMA_NAME}.hosts(id),
            price VARCHAR(20),
            created_at TIMESTAMP,
            updated_at TIMESTAMP
        )
    """)
    cur.execute(f"""
        CREATE TABLE IF NOT EXISTS {SCHEMA_NAME}.reviews (
            id SERIAL PRIMARY KEY,
            listing_id INTEGER REFERENCES {SCHEMA_NAME}.listings(id),
            reviewer_name VARCHAR(255),
            comments TEXT,
            sentiment VARCHAR(50),
            date TIMESTAMP
        )
    """)

# Function to generate and insert synthetic data
def generate_data(num_hosts=10, num_listings_per_host=3, num_reviews_per_listing=5):
    """Generate and insert synthetic data."""

    # Connect to the database
    conn = psycopg2.connect(
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD,
        host=DB_HOST
    )
    # Create a cursor
    cur = conn.cursor()
    
    # Create tables
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
            f"""INSERT INTO {SCHEMA_NAME}.hosts (name, host_is_superhost, created_at, updated_at)
               VALUES (%s, %s, %s, %s) RETURNING id""",
            (name, is_superhost, created_at, updated_at)
        )

        # Get the generated host ID
        host_id = cur.fetchone()[0]
        host_ids.append(host_id)

    # Commit the transaction
    conn.commit()
    
    # Generate listings for each host
    listing_ids = []
    for host_id in host_ids:
        for _ in range(num_listings_per_host):

            # Create random data for each column
            name = fake.sentence(nb_words=3).replace('.', '')  # Example: "Cozy beachfront villa"
            room_type = random.choice(['Entire home', 'Private room', 'Shared room'])
            minimum_nights = random.randint(1, 30)
            price = f"${random.randint(50, 300)}.{random.randint(0, 99):02d}"
            created_at = fake.date_time_this_decade()
            updated_at = fake.date_time_between(created_at, datetime.now())

            # Insert listing
            cur.execute(
                f"""INSERT INTO {SCHEMA_NAME}.listings (name, room_type, minimum_nights, host_id, price, created_at, updated_at)
                   VALUES (%s, %s, %s, %s, %s, %s, %s) RETURNING id""",
                (name, room_type, minimum_nights, host_id, price, created_at, updated_at)
            )

            # Get the generated listing ID
            listing_id = cur.fetchone()[0]
            listing_ids.append(listing_id)

    # Commit the transaction
    conn.commit()
    
    # Generate reviews for each listing
    for listing_id in listing_ids:
        for _ in range(num_reviews_per_listing):

            # Create random data for each column
            reviewer_name = fake.name()
            comments = fake.text(max_nb_chars=200)
            sentiment = random.choice(['positive', 'neutral', 'negative'])

            # Ensure review date is after listing creation
            cur.execute(f"SELECT created_at FROM {SCHEMA_NAME}.listings WHERE id = %s", (listing_id,))
            listing_created_at = cur.fetchone()[0]
            date = fake.date_time_between(listing_created_at, datetime.now())

            # Insert review
            cur.execute(
                f"""INSERT INTO {SCHEMA_NAME}.reviews (listing_id, reviewer_name, comments, sentiment, date)
                   VALUES (%s, %s, %s, %s, %s)""",
                (listing_id, reviewer_name, comments, sentiment, date)
            )
    # Commit the transaction
    conn.commit()
    
    # Close connection
    cur.close()
    conn.close()

if __name__ == "__main__":
    generate_data()