create database Retail_data;
use Retail_data;

-- question of the project

/*
Write SQL queries to get the required output for following business scenarios. 
Notes: 
• Only one SQL query should be written for each question. 
• SQL queries should be written keeping in mind that you have read only access. 
• You can insert 1000 records only using the INSERT in one INSERT statement in MS SQL 
Server. To insert more records, use INSERT statement again. 
DATA PREPARATION AND UNDERSTANDING 
*/

--1. What is the total number of rows in each of the 3 tables in the database? 


Select COUNT (*) as cnt from Customer
union
select COUNT (*) as cnt from prod_cat_info
union
select COUNT (*) as cnt from Transactions




--2. What is the total number of transactions that have a return? 

select COUNT(distinct(transaction_id)) as tot_trans from Transactions
where Qty < 0



/*3. As you would have noticed, the dates provided across the datasets are not in a 
correct format. As first steps, pls convert the date variables into valid date formats 
before proceeding ahead. */

select CONVERT(date,tran_date,105) as trasn_dates from Transactions




/*4. What is the time range of the transaction data available for analysis? Show the 
output in number of days, months and years simultaneously in different columns.
*/

select DATEDIFF(YEAR,MIN(CONVERT(date,tran_date,105)),MAX(CONVERT(DATE,tran_date,105))) As diff_years
from Transactions

select DATEDIFF(MONTH,MIN(CONVERT(date,tran_date,105)),MAX(CONVERT(DATE,tran_date,105))) As diff_years
from Transactions

select DATEDIFF(DAY,MIN(CONVERT(date,tran_date,105)),MAX(CONVERT(DATE,tran_date,105))) As diff_years
from Transactions

--5. Which product category does the sub-category "DIY" belong to? 

select prod_cat,prod_subcat from prod_cat_info
where prod_subcat = 'DIY'



/*
DATA ANALYSIS
*/
SELECT TOP 1 * FROM Customer
SELECT TOP 1 * FROM prod_cat_info
SELECT TOP 1 * FROM Transactions

--1) Which channel is most frequently used for transactions?


select store_type,Count(*) as cnt from Transactions
group by Store_type
order by cnt desc


--2)What is the count of Male and Female customers in the database?


select gender, COUNT(*) as cnt from Customer
where Gender is not null  
group by Gender

--3)From which city do we have the maximum number of customers and how many?
select city_code, count(*) as cnt from Customer
group by city_code
order by cnt desc

--4) How many sub-categories are there under the Books category?
 
select prod_cat, prod_subcat from prod_cat_info
where prod_cat = 'Books'

 --5) What is the maximum quantity of products ever ordered?

 Select prod_cat_code, max(qty) as max_prod from transactions
 Group by prod_cat_code

 --6)What is the net total revenue generated in categories Electronics and Books?


 select sum (cast(total_amt as float)) as net_revenue from prod_cat_info as t1
 join Transactions as t2
 on t1.prod_cat_code = T2.prod_cat_code AND t1.prod_sub_cat_code = t2.prod_subcat_code 
 where prod_cat = 'Books' OR prod_cat = 'Electornics'

 --7) How many customers have >10 transactions with us, excluding returns?


select COUNT(*) as tot_cust from (
select Cust_id , count(distinct(Transaction_id)) as cnt_trans from Transactions
where qty > 0
group by cust_id
having count(distinct(Transaction_id)) >10
) as t5

--8)What is the combined revenue earned from the “Electronics” & “Clothing” categories, from “Flagship stores”?


select SUM(cast(Total_amt as float)) as combined_revenue from prod_cat_info as t1
 join Transactions as t2
 on t1.prod_cat_code = T2.prod_cat_code AND t1.prod_sub_cat_code = t2.prod_subcat_code 
 where prod_cat in('clothing','Electronics') AND store_type = 'Flagship stores' and Qty > 0

 --9)What is the total revenue generated from “Male” customers in “Electronics” category? Output should display total revenue by prod sub-cat.

 select SUM(cast(Total_amt as float))as tot_revenue from Customer as t1
 join Transactions as t2
 on t1.customer_Id = t2.cust_id
 join prod_cat_info as t3
 on t2.prod_cat_code = t3.prod_cat_code and t2.prod_cat_code = t3.prod_sub_cat_code
 where Gender = 'M' and prod_cat = 'Electronics'


 --10)What is percentage of sales and returns by product sub category; display only top 5 sub categories in terms of sales?



 -- percentage of sales
 select t5.prod_subcat, percentage_sales,percentage_returns from (
 Select top 5 prod_subcat,(SUM(cast(total_amt as float))/(select SUM(cast(total_amt as float)) as tot_sales from Transactions where Qty >0)) as percentage_sales
 from prod_cat_info as t1
 join Transactions as t2
 on t1.prod_cat_code = T2.prod_cat_code AND t1.prod_sub_cat_code = t2.prod_subcat_code
 where qty > 0
 group by prod_subcat
 order by percentage_sales desc
 ) as t5
 join
 --percentage of returns
 (
 Select prod_subcat,(SUM(cast(total_amt as float))/(select SUM(cast(total_amt as float)) as tot_sales from Transactions where Qty >0)) as percentage_returns
 from prod_cat_info as t1
 join Transactions as t2
 on t1.prod_cat_code = T2.prod_cat_code AND t1.prod_sub_cat_code = t2.prod_subcat_code
 where qty > 0
 group by prod_subcat ) as t6
 on t5.prod_subcat = t6.prod_subcat


 --  11)For all customers aged between 25 to 35 years find what is the net total revenue generated by these consumers in last 30 days of transactions from max transaction date available in the data?



 SELECT TOP 1 * FROM Customer
SELECT TOP 1 * FROM prod_cat_info
SELECT TOP 1 * FROM Transactions

--age of customer

Select * from (

select * from (
Select cust_id, DATEDIFF (YEAR, dob, max_date)as Age ,revenue from (  
Select cust_id, dob, max(convert(date, tran_date,105)) as max_date, sum(cast (total_amt as float )) as revenue from Customer as t1
join transactions as t2
on t1.customer_Id = t2.cust_id
where qty > 0
group by cust_id, DOB
) as A
        ) as B
where Age between 25 and 35

                            ) as C
join (

--last 30 days of transactions
select cust_id, convert(date, tran_date,105) as tran_date 
from Transactions
group by cust_id, convert(date, tran_date,105)
having convert(date, tran_date,105) >= (Select dateadd (day, -30,max(convert(date, tran_date,105))) as max_date from Transactions)
) as D
on C.cust_id=d.cust_id


--12)Which product category has seen the max value of returns in the last 3 months of transactions?


SELECT 
    prod_cat_code, 
    CONVERT(DATE, tran_date, 105) AS tran_date, 
    SUM(CAST(qty AS INT)) AS returns
FROM Transactions
WHERE CAST(qty AS INT) < 0
GROUP BY prod_cat_code, CONVERT(DATE, tran_date, 105)
HAVING CONVERT(DATE, tran_date, 105) >= (
    SELECT DATEADD(MONTH, -3, MAX(CONVERT(DATE, tran_date, 105))) 
    FROM Transactions
);


--13) Which store-type sells the maximum products; by value of sales amount and by quantity sold?



 SELECT TOP 1 * FROM Customer
SELECT TOP 1 * FROM prod_cat_info
SELECT TOP 1 * FROM Transactions


SELECT 
    store_type, 
    SUM(CAST(total_amt AS FLOAT)) AS revenue, 
    SUM(CAST(qty AS INT)) AS quantity
FROM Transactions
WHERE CAST(qty AS INT) > 0
GROUP BY store_type
ORDER BY revenue DESC, quantity DESC;


--14)What are the categories for which average revenue is above the overall average.


Select prod_cat_code, AVG(cast(total_amt as float)) as avg_revenue from Transactions
where qty > 0
group by prod_cat_code
having AVG(cast(total_amt as float)) >= (select avg(cast(total_amt as float)) from transactions where qty >0)

--15) Find the average and total revenue by each subcategory for the categories which are among top 5 categories in terms of quantity sold.



-- to check datatype
         SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'Transactions';


SELECT 
    prod_subcat_code, 
    SUM(CAST(total_amt AS FLOAT)) AS revenue, 
    AVG(CAST(total_amt AS FLOAT)) AS avg_revenue
FROM Transactions
WHERE 
    CAST(Qty AS FLOAT) > 0 
    AND prod_cat_code IN ( 
        SELECT TOP 5 prod_cat_code 
        FROM Transactions
        WHERE CAST(Qty AS FLOAT) > 0
        GROUP BY prod_cat_code
        ORDER BY SUM(CAST(Qty AS FLOAT)) DESC 
    )
GROUP BY prod_subcat_code;
