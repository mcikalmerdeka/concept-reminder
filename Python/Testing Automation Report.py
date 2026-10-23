import pandas as pd
import schedule
import time
from datetime import datetime

# Function to generate a report
def generate_report():
    # Simulate data extraction
    data = {
        'Date': pd.date_range(start='2023-10-01', periods=7),
        'Metric_A': [100, 120, 140, 160, 180, 200, 220],
        'Metric_B': [50, 60, 70, 80, 90, 100, 110]
    }
    
    df = pd.DataFrame(data)
    
    # Perform analysis (here, a simple summary)
    summary = df.describe()
    
    # Generate Excel report
    report_name = f"report_{datetime.now().strftime('%Y%m%d')}.xlsx"
    with pd.ExcelWriter(report_name, engine='openpyxl') as writer:
        df.to_excel(writer, sheet_name='Raw_Data')
        summary.to_excel(writer, sheet_name='Summary')
    
    print(f"Report generated: {report_name}")

# Scheduling the task
def schedule_report():
    # Schedule daily report at 9:00 AM
    schedule.every().day.at("09:00").do(generate_report)
    
    while True:
        schedule.run_pending()
        time.sleep(60)  # Check every minute if it's time to run the task

# Call the scheduling function
schedule_report()


# ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

import pandas as pd
import schedule
import time
import logging
import mysql.connector
from datetime import datetime
import matplotlib.pyplot as plt

# Configure logging
logging.basicConfig(filename='report_log.log', level=logging.INFO, 
                    format='%(asctime)s:%(levelname)s:%(message)s')

# Database connection settings (example with MySQL)
def connect_db():
    try:
        connection = mysql.connector.connect(
            host='localhost',
            user='your_username',
            password='your_password',
            database='your_database'
        )
        return connection
    except mysql.connector.Error as err:
        logging.error(f"Database connection failed: {err}")
        return None

# Function to extract data
def extract_data():
    conn = connect_db()
    if conn:
        try:
            query = """
            SELECT date, metric_a, metric_b 
            FROM product_metrics 
            WHERE date >= CURDATE() - INTERVAL 7 DAY;
            """
            df = pd.read_sql(query, conn)
            conn.close()
            return df
        except Exception as e:
            logging.error(f"Data extraction failed: {e}")
            return None
    return None

# Function to perform advanced data analysis
def analyze_data(df):
    try:
        # Adding a rolling average as an example of advanced analysis
        df['Metric_A_RollingAvg'] = df['metric_a'].rolling(window=3).mean()
        df['Metric_B_RollingAvg'] = df['metric_b'].rolling(window=3).mean()
        return df.describe()
    except Exception as e:
        logging.error(f"Data analysis failed: {e}")
        return None

# Function to create visualizations
def create_visualization(df, report_name):
    try:
        plt.figure(figsize=(10, 6))
        
        # Plot Metric A and its rolling average
        plt.plot(df['date'], df['metric_a'], label='Metric A', color='blue')
        plt.plot(df['date'], df['Metric_A_RollingAvg'], label='Metric A - Rolling Avg', color='cyan', linestyle='--')
        
        # Plot Metric B and its rolling average
        plt.plot(df['date'], df['metric_b'], label='Metric B', color='green')
        plt.plot(df['date'], df['Metric_B_RollingAvg'], label='Metric B - Rolling Avg', color='lime', linestyle='--')
        
        plt.title('Product Metrics Over Time')
        plt.xlabel('Date')
        plt.ylabel('Value')
        plt.legend()
        plt.grid(True)
        
        # Save the plot as an image
        plt.savefig(f'{report_name}_chart.png')
        plt.close()
        
        logging.info(f"Visualization created for {report_name}")
    except Exception as e:
        logging.error(f"Visualization failed: {e}")

# Function to generate report with analysis and visualization
def generate_report():
    try:
        # Extract data from the database
        df = extract_data()
        if df is None or df.empty:
            logging.error("No data to generate the report.")
            return
        
        # Perform analysis
        summary = analyze_data(df)
        if summary is None:
            logging.error("Failed to analyze data.")
            return
        
        # Create report filename
        report_name = f"report_{datetime.now().strftime('%Y%m%d')}"
        
        # Save report to Excel
        with pd.ExcelWriter(f'{report_name}.xlsx', engine='openpyxl') as writer:
            df.to_excel(writer, sheet_name='Raw_Data', index=False)
            summary.to_excel(writer, sheet_name='Summary')
        
        # Create visualization and save as PNG
        create_visualization(df, report_name)
        
        logging.info(f"Report generated successfully: {report_name}.xlsx")
        
    except Exception as e:
        logging.error(f"Report generation failed: {e}")

# Function to schedule the task
def schedule_report(frequency="daily"):
    try:
        if frequency == "daily":
            # Schedule daily report at 9:00 AM
            schedule.every().day.at("09:00").do(generate_report)
        elif frequency == "weekly":
            # Schedule weekly report on Mondays at 9:00 AM
            schedule.every().monday.at("09:00").do(generate_report)
        
        logging.info(f"Scheduled report generation: {frequency}")
        
        while True:
            schedule.run_pending()
            time.sleep(60)  # Check every minute if it's time to run the task
    except Exception as e:
        logging.error(f"Scheduling failed: {e}")

# Start scheduling with desired frequency
schedule_report(frequency="daily")
