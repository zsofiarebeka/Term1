# Data Engineering 1 - Term project 1

Sakila is a well-known sample relational dataset which represents a fictional DVD rental store. 
I found and loaded the data from the Relational dataset repository. (Source: https://relational.fit.cvut.cz/dataset/Sakila)

## The Sakila dataset contains:
- 16 tables
- 47,010 rows and 89 columns
- Numeric, string, LOB (large objects), and temporal data types
- Some missing values
- And its size is 6.4 MB.

## 1. Database Setup:
I downloaded the SQL files containing the data and schema that was provided on the internet. I cleaned them and deleted unnecessary parts, e.g. default exercises and solutions, copyright warnings. I designed and created a denormalized table to optimize data for analytical queries. 

## 2. Data Analysis Queries:
The aspects that I proposed are the following:

# Customer Analysis: 
- Which cities have the highest average rental duration?
- Who are the top 5 renters and how many rentals they had?
- Which customers returned their rented movies late?
Understanding the demographics of your renters (e.g. location) can help you tailor your marketing efforts and product offerings to specific customer segments.

# Film and Genre Analysis:
- What is the most popular genre with the highest number of rentals?
- How many copies of a specific film are currently available for rent?
- What is the total revenue generated for each film genre?
Understanding which genres generate the most revenue helps in optimizing inventory, marketing strategies, and expanding offerings. By knowing how many copies of a specific film are available, we can ensure that popular titles have enough copies in stock to meet customer demand and we can maximize revenue potential. This prevents situations where customers can't rent their desired film due to insufficient copies. Moreover, for less popular movies, we can reevaluate their rental potential and optimize their inventory. This information can also be used for marketing and promotions.

# Revenue and performance analysis:
This analysis helps to identify the most profitable films in terms of rental fees. It provides insights into customer preferences and helps in decision-making for film acquisition and promotion. The aspects I have discovered were:
- What are the total revenues of the top rented movies?
- Generating a monthly report (E.g.: for February, 2006)
- What is the total monthly revenue?

# 3. Stored Procedures
I created stored procedures to encapsulate and execute some mentioned analytical queries.

# 4. ETL (Extract, Transform, Load) Operations:
I performed ETL operations by extracting data from the data warehouse table (analytical_layer), transforming it to meet specific analysis requirements, and loading it into views and tables.

# 5. Event Scheduler
I set up an event scheduler to automate am ETL job, which in my case was generating a monthly report. This procedure automates the process of generating monthly reports, making it efficient and convenient for management to track revenue trends over time.

