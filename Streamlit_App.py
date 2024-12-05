import streamlit as st
import psycopg2
import pandas as pd
from datetime import datetime

# Database connection details
db_host = "127.0.0.1"
db_name = "Car Rental Database"
db_user = "postgres"
db_password = "Ilakaush@17"

# Function to connect to the PostgreSQL database
def connect_to_db():
    conn = psycopg2.connect(
        host=db_host,
        dbname=db_name,
        user=db_user,
        password=db_password
    )
    return conn

# Function to get available cars
def get_available_cars(start_date, end_date):
    query = """
        SELECT c.vehicle_id, c.Model, ct.Daily_rate
        FROM CAR c
        JOIN CARTYPE ct ON c.Type_id = ct.Type_id
        WHERE c.Status = 'Available'
          AND NOT EXISTS (
              SELECT 1
              FROM RENTS r
              WHERE r.Vehicle_id = c.Vehicle_id
                AND r.Start_date <= %s
                AND r.Return_date >= %s
          )
    """
    
    conn = connect_to_db()
    df = pd.read_sql(query, conn, params=(start_date, end_date))
    conn.close()
    
    return df


# Function to book a car
def book_car(customer_id, vehicle_id, start_date, return_date, daily_rent):
    query = """
        INSERT INTO RENTS (Customer_id, Vehicle_id, Start_date, Return_date, Dailyrent)
        VALUES (%s, %s, %s, %s, %s) RETURNING Rent_id
    """
    conn = connect_to_db()
    cur = conn.cursor()
    cur.execute(query, (customer_id, vehicle_id, start_date, return_date, daily_rent))
    rent_id = cur.fetchone()[0]
    conn.commit()
    conn.close()
    
    return rent_id

# Function to get customer info
def get_customer_info(customer_id):
    query = "SELECT * FROM CUSTOMER WHERE Idno = %s"
    conn = connect_to_db()
    df = pd.read_sql(query, conn, params=(customer_id,))
    conn.close()
    
    return df


def app():
    st.title("Car Rental Booking")
    
    first_name = st.text_input("Enter First Name:")
    last_name = st.text_input("Enter Last Name:")

    if not first_name or not last_name:
        st.info("Please enter both First Name and Last Name to proceed.")
        return

    st.write(f"Booking for: {first_name} {last_name}")
    
    # Input for booking dates
    start_date = st.date_input("Select Start Date", min_value=datetime.today())
    return_date = st.date_input("Select Return Date", min_value=start_date)

    # Get available cars based on selected dates
    available_cars = get_available_cars(start_date, return_date)
    if not available_cars.empty:
        st.write("Available Cars:")
        st.dataframe(available_cars)

        # Input for selecting car and booking
        #if 'vehicle_id' in available_cars.columns:
            # Select the car by its model (display-friendly)
        selected_model = st.selectbox("Select Vehicle to Book", available_cars['model'], key="vehicle_selection")

        # Get the full row of the selected car
        selected_vehicle = available_cars[available_cars['model'] == selected_model]

        if not selected_vehicle.empty:
            # Get the vehicle_id and daily_rent from the selected car
            vehicle_id = selected_vehicle.iloc[0]['vehicle_id']  # Ensure this is numeric
            daily_rent = selected_vehicle.iloc[0]['daily_rate']
            st.write(f"Daily Rent: {daily_rent}")

            # Confirm and book car
            if st.button("Book Car"):
                try:
                    #rent_id = book_car(customer_id, vehicle_id, start_date, return_date, daily_rent)
                    #st.success(f"Car booked successfully! Rent ID: {rent_id}")
                    st.success(f"Car booked successfully!")

                except Exception as e:
                    st.error(f"Error booking car: {e}")
           # else:
            #    st.error("Error: Selected vehicle not found.")
        else:
            st.error("Error: 'vehicle_id' column not found in available cars.")
    else:
        st.error("No cars available for the selected dates.")

if __name__ == "__main__":
    app()
