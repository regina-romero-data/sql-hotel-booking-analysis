# sql-hotel-booking-analysis
Exploratory data analysis project focused on identifying booking trends and cancellation patterns using SQL queries, aggregations and joins to extract business insights.
# delete columns that do not cotnribute value to the analysis
/*This code deletes booking_id column
ALTER TABLE HotelReservations
DROP COLUMN booking_id;
SELECT * FROM HotelReservations
# Rename columns for an easier lecture
/* This code renames all columns to more readable names
ALTER table HotelReservations rename column no_of_adults to adults;
ALTER table HotelReservations rename column no_of_children to children;
ALTER table HotelReservations rename column no_of_weekend_nights to weekend_nights;
ALTER table HotelReservations rename column no_of_week_nights to week_nights;
ALTER table HotelReservations rename column type_of_meal_plan to meal_plan;
ALTER table HotelReservations rename column required_car_parking_space to parking_space;
ALTER table HotelReservations rename column market_segment_type to market_segment;
ALTER table HotelReservations rename column no_of_previous_cancellations to previous_cancellations;
ALTER table HotelReservations rename column no_of_previous_bookings_not_canceled to previous_bookings;
ALTER table HotelReservations rename column avg_price_per_room to price_per_room;
ALTER table HotelReservations rename column no_of_special_requests to special_requests;
# Create a new column : total guests
/* This code adds the total_guests table using the INTEGER function
ALTER TABLE HotelReservations
ADD COLUMN total_guests INTEGER;
SELECT * FROM HotelReservations
/* This code updates the table where total_guests is calculated as the total number of adults and children
UPDATE HotelReservations
SET total_guests = adults + children;
/* Adults, children, and total_guests are selected to use the condition that children are greater than 0
SELECT adults, children, total_guests FROM HotelReservations WHERE children>0;
# Create a new column total nights per reservation
/* A new column called total_nights is added
CÓDIGO UTILIZADO:
ALTER TABLE HotelReservations
ADD COLUMN total_nights INTEGER;
/* This code assigns a value to the total_nights column by adding week_nights and weekend_nights.
UPDATE HotelReservations
SET total_nights = week_nights + weekend_nights;
select weekend_nights, week_nights, total_nights from HotelReservations
/* In this code, a new column called total_revenue_estimated is added and integrated with the INTEGER function.
ALTER TABLE HotelReservations
ADD COLUMN total_revenue_estimated INTEGER;
SELECT * FROM HotelReservations
/* The value of the variable total_revenue_estimated is given by multiplying the value of price_per_room by total_nights
UPDATE HotelReservations
SET total_revenue_estimated = ROUND(price_per_room * total_nights , 2)
/* ROUND is used to round to two variables
/*This code aims to improve the visualization of the multiplication performed by price_per_room and total_nights
SELECT price_per_room, total_nights, total_revenue_estimated FROM HotelReservations
# Insights using SQL
/* Displaying unique values ​​in meal_plan
SELECT DISTINCT (meal_plan) FROM HotelReservations
/* This code aims to group the average income of the meal_plans taking into account the average price_per_room
SELECT
meal_plan as plan_alimenticio,
ROUND(AVG(price_per_room), 2) AS ingreso_promedio
FROM
HotelReservations
/* Only data where the reservation status is other than cancelled will be considered
WHERE booking_status != 'Canceled'
GROUP BY
meal_plan;
# total guests per room type
/*The goal is to obtain the sum of the people who have booked, grouped by different room types.
SELECT
room_type_reserved AS tipo_habitacion,
SUM(total_guests) AS total_huespedes
FROM
HotelReservations WHERE booking_status != 'Canceled'
GROUP BY
room_type_reserved;
# Percentage of repeat guest 
/*The total number of guests is summarized
SELECT SUM(total_guests) AS total_guests,
/*A subquery is performed to filter out duplicate guests using the WHERE condition
(SELECT SUM(total_guests) FROM HotelReservations WHERE repeated_guest=1
) AS total_duplicated_guests
/*Only reservations that have not been cancelled are considered
FROM HotelReservations WHERE booking_status != 'Canceled'
# Top 5 market segments with the highest estimated revenue
/*The values ​​resulting from multiplying the price per room by the total number of nights are summed and stored in the average_income variable, because they will be grouped below
SELECT
market_segment,
SUM(price_per_room * (total_nights)) AS ingreso_estimado
FROM HotelReservations
/* Data was used only from customers who did not cancel their reservation, filtered by the where function
WHERE booking_status != 'Canceled'
/* The result of the sum of estimated income is now grouped by market segment
GROUP BY market_segment
/* Sorted in descending order
ORDER BY ingreso_estimado DESC
/* A limit of 5 is sought
LIMIT 5;
# Arrival day with the most bookings
/*The goal is to count how many people booked (total_reservations) grouped by arrival date (arrival_date)
SELECT
arrival_date,
COUNT(*) AS total_reservas
FROM HotelReservations WHERE booking_status != 'Canceled'
GROUP BY arrival_date
/* the total number of reservations is sorted in descending order
ORDER BY total_reservas DESC;
# Average number of nights and special requests per room
/* The goal is to calculate the average of the total_nights to two decimal places and save it as average_nights
SELECT room_type_reserved,
ROUND(AVG(total_nights),2) AS promedio_noches,
/*The goal is to average the special_request to two decimal places and save it as average_special_requests
ROUND(AVG(special_requests),2) AS promedio_solicitudes_especiales
/* Only data from people whose status is not cancelled were used
FROM HotelReservations WHERE booking_status != 'Canceled'
/* The result was grouped by room_type_reserved
GROUP BY room_type_reserved;
# Guests with a history of cancellations and high spending (advanced analysis)
/* Count the number of rows that meet the given conditions
SELECT COUNT(*)
/* Only the data of people who did not cancel is retained
FROM HotelReservations
WHERE booking_status != 'Canceled'
/* Filter by bookings from customers who had canceled at least once before
AND previous_cancellations > 0
/* Filter by room price higher than the average of all uncancelled bookings
AND price_per_room > (
SELECT AVG(price_per_room) FROM HotelReservations WHERE booking_status != 'Canceled' );
/* Select columns for which you want to know the data
SELECT market_segment, room_type_reserved, repeated_guest, total_guests
FROM HotelReservations
/* The condition of only working with uncancelled reservations must be met
WHERE booking_status != 'Canceled'
/* Filter by room price that is higher than the average of all uncancelled reservations
AND previous_cancellations > 0
AND price_per_room > (
SELECT AVG(price_per_room) FROM HotelReservations WHERE booking_status != 'Canceled' );

