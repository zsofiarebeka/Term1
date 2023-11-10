
-- -----------------
-- ANALYTICS PLAN --
-- -----------------

-- 1. CUSTOMER ANALYSIS
-- 1.1. Customer Demographics: Which cities have the highest average rental duration?
-- 1.2. Top Renters: Who are the top 5 renters and how many rentals they had?
-- 1.3. Late Returners: Which customers returned their rented movies late?

-- 2. FILM AND GENRE ANALYSIS
-- 2.1. Most popular genre: What is the most popular genre with the highest number of rentals?
-- 2.2. Film availability: How many copies of a specific film are currently available for rent?
-- 2.3. Total revenue per film: What is the total revenue generated for each film genre?

-- 3. REVENUE ANALYSIS
-- 3.1. Top Revenues: What are the total revenues of the top rented movies?
-- 3.2. Monthly Report: Generating a monthly report (E.g.: for February, 2006)
-- 3.3. Monthly Revenue: What is the total monthly revenue?

use sakila;
select * from analytical_layer;

DROP PROCEDURE IF EXISTS AvgRentalDuration;

DELIMITER //

CREATE PROCEDURE AvgRentalDuration()
BEGIN
    DROP TABLE IF EXISTS AvgRentalDuration;
    CREATE TABLE AvgRentalDuration AS
    SELECT 
        a.City,
        a.Country,
        AVG(DATEDIFF(a.return_date, a.rental_date)) AS AverageRentalDuration
    FROM 
       analytical_layer a
    GROUP BY
        City, Country
    ORDER BY 
        AverageRentalDuration DESC;
END //

DELIMITER ;

-- To display the values
CALL AvgRentalDuration();

-- Checking if store procedure works and table exists
SELECT * FROM AvgRentalDuration;

    
-- 1.2. Top Renters: Who are the top 5 renters and how many rentals have they had?

DROP PROCEDURE IF EXISTS TopRenters;

DELIMITER //

CREATE PROCEDURE TopRenters()
BEGIN
	DROP TABLE IF EXISTS TopRenters;
    CREATE TABLE TopRenters AS
    SELECT 
        customer_id,
        first_name,
        last_name,
        COUNT(rental_id) as rental_count
    FROM analytical_layer
    GROUP BY customer_id, first_name, last_name
    ORDER BY rental_count DESC LIMIT 5;
END //

DELIMITER ;

CALL TopRenters();

-- To display the values
SELECT * FROM TopRenters;

-- 1.3. Late Returners: Which customers returned their rented movies late?

DROP PROCEDURE IF EXISTS LateReturns;

DELIMITER //

CREATE PROCEDURE LateReturns()
BEGIN
    SELECT 
        a.first_name,
        a.last_name,
        a.rental_date,
        a.return_date,
        a.film_rental_duration AS allowed_rental_duration,
        DATEDIFF(a.return_date, a.rental_date) AS renting_time,
        DATEDIFF(a.return_date, a.rental_date) - CAST(a.film_rental_duration AS SIGNED) AS days_of_delay
    FROM analytical_layer a
    WHERE DATE(a.return_date) > DATE(a.rental_date)
    ORDER BY a.return_date DESC;
END //

DELIMITER ;

-- To display the values
CALL LateReturns();
    
--
-- 2. FILM AND GENRE ANALYSIS
--

-- 2.1. Most popular genre: What is the most popular genre with the highest number of rentals?

DELIMITER //

DROP PROCEDURE IF EXISTS MostPopularGenre;

CREATE PROCEDURE MostPopularGenre()
BEGIN
    SELECT 
        category_name AS genre,
        COUNT(rental_id) AS num_rentals
    FROM analytical_layer
    GROUP BY category_name
    ORDER BY num_rentals DESC LIMIT 1;
END //

DELIMITER ;

-- To display the values
CALL MostPopularGenre();

-- 2.2. Film availability: How many copies of a specific film are currently available for rent?

DELIMITER //

DROP PROCEDURE IF EXISTS FilmAvailableCopies;

CREATE PROCEDURE FilmAvailableCopies()
BEGIN
    SELECT 
        film_title AS Film_Title,
        COUNT(inventory_id) AS Available_Copies
    FROM analytical_layer
    WHERE return_date IS NULL
    GROUP BY film_title;
END //

DELIMITER ;

-- To display the values
CALL FilmAvailableCopies();

-- 2.3. Calculating the total revenue generated for each film genre

DELIMITER //

DROP PROCEDURE IF EXISTS TotalRevenuePerGenre;

CREATE PROCEDURE TotalRevenuePerGenre()
BEGIN
    SELECT 
        category_name AS Genre,
        SUM(payment_amount) AS Total_Revenue
    FROM analytical_layer
    GROUP BY category_name
    ORDER BY Total_Revenue DESC;
END //

DELIMITER ;

-- To display the values
CALL TotalRevenuePerGenre();

--
-- 3. REVENUE ANALYSIS
--

-- 3.1. Top total revenues of each rented movie

DROP PROCEDURE IF EXISTS TopTotalRevenues;

DELIMITER //
CREATE PROCEDURE TopTotalRevenues()
BEGIN
SELECT 
    film.title AS Film_Title,
    SUM(payment.amount) AS Total_Revenue
FROM film
    JOIN inventory ON film.film_id = inventory.film_id
    JOIN rental ON inventory.inventory_id = rental.inventory_id
    JOIN payment ON rental.rental_id = payment.rental_id
GROUP BY film.title
ORDER BY Total_Revenue DESC LIMIT 10;
END //

DELIMITER ;

-- To display the values
CALL TopTotalRevenues();

-- 3.2. Generating a monthly report for February, 2006

DROP PROCEDURE IF EXISTS MonthlyReport;

DELIMITER //

CREATE PROCEDURE MonthlyReport (IN reportMonth INT, IN reportYear INT)
BEGIN
    SELECT 
        first_name,
        last_name,
        film_title,
        rental_date,
        return_date,
        SUM(payment_amount) AS total_payment,
        COUNT(inventory_id) AS inventory_count
    FROM analytical_layer
    WHERE YEAR(rental_date) = reportYear
        AND MONTH(rental_date) = reportMonth
    GROUP BY first_name, last_name, film_title, rental_date, return_date;
END //

DELIMITER ;

-- To display the values
CALL MonthlyReport(2, 2006);

-- 3.3. Monthly Revenue: What is the total monthly revenue?

DROP PROCEDURE IF EXISTS CalculateMonthlyRevenue;

DELIMITER //

CREATE PROCEDURE CalculateMonthlyRevenue()
BEGIN
    -- Drop the table if it exists
    DROP TABLE IF EXISTS monthly_revenue;

    -- Create the monthly_revenue table
    CREATE TABLE monthly_revenue AS
    SELECT
        YEAR(rental_date) AS year,
        MONTH(rental_date) AS month,
        SUM(payment_amount) AS total_revenue
    FROM analytical_layer
    GROUP BY year, month;

END //

DELIMITER ;

-- To display the values
CALL CalculateMonthlyRevenue();

-- Checking if the stored procedure created the correct table
SELECT * FROM monthly_revenue;


-- ---------------------
-- 4. SCHEDULED EVENT --
-- ---------------------

-- Creating an event to calculate monthly revenue

SET GLOBAL event_scheduler = ON;

DROP EVENT IF EXISTS CalculateMonthlyRevenueEvent;

DELIMITER //

CREATE EVENT CalculateMonthlyRevenueEvent
ON SCHEDULE 
  EVERY 1 MONTH
  STARTS DATE_FORMAT(NOW() + INTERVAL 1 MONTH, '%Y-%m-01')
DO
BEGIN
  CALL CalculateMonthlyRevenue();
  
END //

DELIMITER ;

-- Checking if the event is stored in the schema -- 
SHOW EVENTS;

-- ----------------
-- 5. DATA MARTS --
-- ----------------

-- Genre Analytics: How do different genres perform?

DROP VIEW IF EXISTS GenrePerformance;
CREATE VIEW GenrePerformance AS
SELECT
    category_id AS genreId,
    category_name AS genreName,
    COUNT(rental_id) AS totalRentals,
    AVG(DATEDIFF(return_date, rental_date)) AS averageRentalDuration,
    SUM(payment_amount) AS totalRevenue
FROM analytical_layer
GROUP BY
    category_id,
    category_name;

-- To display the contents of the view
SELECT * FROM GenrePerformance;

-- Customer Rental Analytics: Providing insights into the rental patterns based on customer activity

DROP VIEW IF EXISTS CustomerRentalAnalysis;
CREATE VIEW CustomerRentalAnalysis AS
SELECT
    customer_id,
    first_name,
    last_name,
    email,
    active,
    COUNT(rental_id) AS totalRentals,
    AVG(DATEDIFF(return_date, rental_date)) AS averageRentalDuration,
    SUM(payment_amount) AS totalRevenue
FROM analytical_layer
GROUP BY customer_id, first_name, last_name, email, active;

-- To display the content 
SELECT * FROM CustomerRentalAnalysis;

-- Checking active renters only
SELECT * FROM CustomerRentalAnalysis WHERE active = 1;















