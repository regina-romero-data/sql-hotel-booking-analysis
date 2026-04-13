-- =============================================================================
-- Hotel Reservations — SQL Exploratory Data Analysis
-- =============================================================================
-- Project:  Hotel Booking Analysis — Business Intelligence
-- Author:   Regina Romero de León
-- Year:     2025
--
-- Description:
--   Exploratory data analysis on hotel reservation data using SQL.
--   Identifies booking trends, cancellation patterns, revenue estimates,
--   and market segment performance to extract actionable business insights.
--
-- Dataset:  HotelReservations
-- Tools:    SQL · Aggregations · Joins · Subqueries · Window Functions
-- =============================================================================


-- =============================================================================
-- 1. DATA CLEANING — REMOVE UNNECESSARY COLUMNS
-- =============================================================================

-- Delete booking_id column as it does not contribute value to the analysis
ALTER TABLE HotelReservations
DROP COLUMN booking_id;

SELECT * FROM HotelReservations;


-- =============================================================================
-- 2. COLUMN RENAMING — IMPROVE READABILITY
-- =============================================================================

ALTER TABLE HotelReservations RENAME COLUMN no_of_adults TO adults;
ALTER TABLE HotelReservations RENAME COLUMN no_of_children TO children;
ALTER TABLE HotelReservations RENAME COLUMN no_of_weekend_nights TO weekend_nights;
ALTER TABLE HotelReservations RENAME COLUMN no_of_week_nights TO week_nights;
ALTER TABLE HotelReservations RENAME COLUMN type_of_meal_plan TO meal_plan;
ALTER TABLE HotelReservations RENAME COLUMN required_car_parking_space TO parking_space;
ALTER TABLE HotelReservations RENAME COLUMN market_segment_type TO market_segment;
ALTER TABLE HotelReservations RENAME COLUMN no_of_previous_cancellations TO previous_cancellations;
ALTER TABLE HotelReservations RENAME COLUMN no_of_previous_bookings_not_canceled TO previous_bookings;
ALTER TABLE HotelReservations RENAME COLUMN avg_price_per_room TO price_per_room;
ALTER TABLE HotelReservations RENAME COLUMN no_of_special_requests TO special_requests;


-- =============================================================================
-- 3. FEATURE ENGINEERING — CREATE NEW COLUMNS
-- =============================================================================

-- --- 3.1 Total Guests per Reservation ---
ALTER TABLE HotelReservations
ADD COLUMN total_guests INTEGER;

UPDATE HotelReservations
SET total_guests = adults + children;

-- Verify: show reservations with children
SELECT adults, children, total_guests
FROM HotelReservations
WHERE children > 0;


-- --- 3.2 Total Nights per Reservation ---
ALTER TABLE HotelReservations
ADD COLUMN total_nights INTEGER;

UPDATE HotelReservations
SET total_nights = week_nights + weekend_nights;

SELECT weekend_nights, week_nights, total_nights
FROM HotelReservations;


-- --- 3.3 Estimated Revenue per Reservation ---
ALTER TABLE HotelReservations
ADD COLUMN total_revenue_estimated INTEGER;

UPDATE HotelReservations
SET total_revenue_estimated = ROUND(price_per_room * total_nights, 2);

-- Verify calculation
SELECT price_per_room, total_nights, total_revenue_estimated
FROM HotelReservations;


-- =============================================================================
-- 4. BUSINESS INSIGHTS
-- =============================================================================

-- --- 4.1 Average Revenue by Meal Plan (excluding cancellations) ---
SELECT DISTINCT meal_plan
FROM HotelReservations;

SELECT
    meal_plan,
    ROUND(AVG(price_per_room), 2) AS average_revenue
FROM HotelReservations
WHERE booking_status != 'Canceled'
GROUP BY meal_plan;


-- --- 4.2 Total Guests by Room Type (excluding cancellations) ---
SELECT
    room_type_reserved,
    SUM(total_guests) AS total_guests
FROM HotelReservations
WHERE booking_status != 'Canceled'
GROUP BY room_type_reserved;


-- --- 4.3 Percentage of Repeat Guests ---
SELECT
    SUM(total_guests) AS total_guests,
    (
        SELECT SUM(total_guests)
        FROM HotelReservations
        WHERE repeated_guest = 1
    ) AS total_repeat_guests
FROM HotelReservations
WHERE booking_status != 'Canceled';


-- --- 4.4 Top 5 Market Segments by Estimated Revenue ---
SELECT
    market_segment,
    SUM(price_per_room * total_nights) AS estimated_revenue
FROM HotelReservations
WHERE booking_status != 'Canceled'
GROUP BY market_segment
ORDER BY estimated_revenue DESC
LIMIT 5;


-- --- 4.5 Arrival Dates with the Most Bookings ---
SELECT
    arrival_date,
    COUNT(*) AS total_reservations
FROM HotelReservations
WHERE booking_status != 'Canceled'
GROUP BY arrival_date
ORDER BY total_reservations DESC;


-- --- 4.6 Average Nights and Special Requests by Room Type ---
SELECT
    room_type_reserved,
    ROUND(AVG(total_nights), 2)       AS average_nights,
    ROUND(AVG(special_requests), 2)   AS average_special_requests
FROM HotelReservations
WHERE booking_status != 'Canceled'
GROUP BY room_type_reserved;


-- =============================================================================
-- 5. ADVANCED ANALYSIS
-- =============================================================================

-- --- 5.1 Count of High-Spending Guests with Cancellation History ---
-- Guests who previously cancelled AND paid above average price
SELECT COUNT(*)
FROM HotelReservations
WHERE booking_status != 'Canceled'
  AND previous_cancellations > 0
  AND price_per_room > (
      SELECT AVG(price_per_room)
      FROM HotelReservations
      WHERE booking_status != 'Canceled'
  );


-- --- 5.2 Profile of High-Spending Guests with Cancellation History ---
SELECT
    market_segment,
    room_type_reserved,
    repeated_guest,
    total_guests
FROM HotelReservations
WHERE booking_status != 'Canceled'
  AND previous_cancellations > 0
  AND price_per_room > (
      SELECT AVG(price_per_room)
      FROM HotelReservations
      WHERE booking_status != 'Canceled'
  );
