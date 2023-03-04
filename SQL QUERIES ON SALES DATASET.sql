DROP database sales;
CREATE DATABASE sales;
use sales;

-- We can also use python library'csvkit' for bulk loading in automatic way
-- 1. OPEN ANACONDA PROMPT
-- 2. C:\Users\win10>D:            (if the file is in D drive)
-- 3. The 'csv file' will be shown
-- 4. Now, install 'csvkit' from pypy repository by writing 'pip install csvkit'
-- 5. Then write:
-- (base)D:\>csvsql --dialect mysql --snifflimit 100000 sales_data_final.csv>output_sales.sql
-- 6. A notepad file will be created which will contain all the table creating query
create table if not exists sales_data(
order_id VARCHAR(15) NOT NULL, 
	order_date VARCHAR(15) NOT NULL, 
	ship_date VARCHAR(15) NOT NULL, 
	ship_mode VARCHAR(14) NOT NULL, 
	customer_name VARCHAR(22) NOT NULL, 
	segment VARCHAR(11) NOT NULL, 
	state VARCHAR(36) NOT NULL, 
	country VARCHAR(32) NOT NULL, 
	market VARCHAR(6) NOT NULL, 
	region VARCHAR(14) NOT NULL, 
	product_id VARCHAR(16) NOT NULL, 
	category VARCHAR(15) NOT NULL, 
	sub_category VARCHAR(11) NOT NULL, 
	product_name VARCHAR(127) NOT NULL, 
	sales DECIMAL(38, 0) NOT NULL, 
	quantity DECIMAL(38, 0) NOT NULL, 
	discount DECIMAL(38, 3) NOT NULL, 
	profit DECIMAL(38, 8) NOT NULL, 
	shipping_cost DECIMAL(38, 2) NOT NULL, 
	order_priority VARCHAR(8) NOT NULL, 
	`year` DECIMAL(38, 0) NOT NULL
);


SELECT * FROM sales_data;

# Bulk upload statement
SET SESSION sql_mode='' ;           # I was getting the error while bulk loading , so used this command-->because there was a comma in the dataset this command will help to parse the datset

LOAD DATA INFILE 'D://INTERNSHIP//DATASETS//sales_data_final.csv'
into table sales_data
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
lines terminated by '\n'
IGNORE 1 ROWS;


#Our data is loaded

SELECT * FROM sales_data;
select str_to_date(order_date,'%m/%d/%y') from sales_data;


# Now, the change is temporary, to keep in permanent wen have to put it into our table wit new column.
# So adding new column in the existing table
#Using"Alter" ---> it will create the column at the last
#But, I want to create "new column" right after the 'order date" column

alter table sales_data
add column order_date_new date after order_date;

select * from sales_Data;
#Now we can see that ---> we have inserted a new column right after order_date; but 
#Now it has "NULL" values
#So, we will set values by using "update

update sales_data
set order_date_new = str_to_date(order_date,'%m/%d/%Y');
# Getting error: 0	52	15:15:31	update sales_data
# set ship_date_new = str_to_date(ship_date,'%m/%d/%y')	Error Code: 1175. You are using safe update mode and you tried to update a table without a WHERE that uses a KEY column. 

#To fix this error:
SET SQL_SAFE_UPDATES=0;        #AFTER RUNNING THIS QUERRY, AGAIN RUN THE ABOVE "UPDATE " QUERY , THE VALUES WILL BE UPDATED IN THE COLUMN


-- Doing same for "shp date
alter table sales_data
add column ship_Date_new date after ship_date;

update sales_data
set ship_date_new = str_to_date(ship_date,'%m/%d/%Y');


SELECT * FROM SALES_DATA;


-- NOTE : Always write "capital Y"  in the date format "%m/%d%Y" otherwise if it is small then it will take the value of "current year"

-- 2. Filter out data in which shipment data =2011-01-05
Select * from sales_Data where ship_date_new='2011-01-05';
Select * from sales_data where ship_date_new > '2011-01-05';
Select * from sales_data where ship_date_new < '2011-01-05';
-- 3. Filter out the data in between "months" 

Select * from sales_data where ship_date_new between '2011-01-05' and '2011-08-30'; # 

-- 4. Get current time of the system

select now();

-- 5. Get current date and time separately
select curdate();
select curtime();



-- 6. Filter out all the sales that has happened before
# date_sub  --> date subtractor function
select * from sales_data where ship_Date_new < date_sub(now() , interval 1 week);
select date_sub(now(), interval 1 week);    #IT WILL GIVE THE DATA OF LAST SATURDAY


select * from sales_data where ship_Date_new < date_sub(now(), interval 30 day);


-- 6. To get the current year

select year(now());

select dayname(now());
select dayname('2022-02-26');

-- 7. Creating one new column in the table and put current date in the entire column
# Like if someone update a record then updation date should be there
#If someone is updating a record day after tomorrow , updating that day
# Concurrent date or maintaing proper time stamt or current date and time is stored 
# Example: Transaction records

Alter table sales_data
add column flag date after order_id; #here we have kept the datatype---> 'date'  So, we can also use 'date time' as 

#Storing current time

update sales_data
set flag = now();

select * from sales_data limit 5;

-- 8. Change the data type of 'year' column from decimal to 'date

# I am facing issue in changing the datatype of "year" column from "decimal" to "datetime"
#So, for now I am changing it to "int" only
ALTER TABLE sales_data
modify column year int;




--  9. Create 3 columns from a single column extracting --> year, month, date


alter table sales_Data
add column Year_new date;

alter table sales_data
add column Month_new date;

alter table sales_data
add column day_new date;

# We have created 3 columns but our data type should be integer in the above case we have taken it as datetime which is a mistake
alter table sales_Data
modify Year_new INT;

alter table sales_data
modify Month_new int;

alter table sales_data
modify day_new int;

update sales_data set Month_new=month(order_date_new);
update sales_Data set day_new = day(order_date_new);
update sales_data set year_new = year(order_date_new);


select * from sales_data limit 5;

-- 10. What was the average sales in 2011, 2012, 2013, 2014 AS we have 4 years of data
Select year_new,AVG(SALES) from sales_data
group by year_new;

# Insight--> We are not increasing the sales year wise as it is decreasing year wise


-- 11.What was the total sales in 2011, 2012, 2013, 2014 AS we have 4 years of data
Select year_new,sum(SALES) from sales_data
group by year_new;

# INSIGHTS: So, sales is not increasing average but total sales is increasing "year wise


-- 12. What was the min sales in 2011, 2012, 2013, 2014 AS we have 4 years of data
Select year_new,min(SALES) from sales_data
group by year_new;

-- 13. What was the max sales in 2011, 2012, 2013, 2014 AS we have 4 years of data

Select year_new,max(SALES) from sales_data
group by year_new;


-- 14. What is the quantity you have sold every year
Select year_new,sum(quantity) from sales_Data 
group by year_new;


#INSIGHTS:  We are increasing the sale of no. of quantity -- or increasing the market cap

SELECT * FROM SALES_DATA LIMIT 5;
-- 15. Find the cost to company
# Cost to company --->Discount and shipment cost
#DISCOUNT IS IN PERCENTAGE

SELECT year,shipping_cost + discount as CTC from sales_data; # This will give wrong results because "discount" is in percentage and we know that discount percentage is of "saless"
select (sales*discount+shipping_cost)  as CTC from sales_data;

-- 16. Segregate  and extract the data into the item which discounted or not?
select order_id,discount,if(discount>0,'yes','no') as discount_flag from sales_data;
select * from sales_data;
-- 17. Make a column  with discount and with not discount

alter table sales_data
add column discount_flag varchar(20) after discount;  #I want my new column after "discount" column
select * from sales_Data;

update sales_data
set discount_flag=if(discount>0,'yes','no');

-- 18. No. of items available for discount and no. of items not available for discount

SELECT discount_flag, count(discount_flag) from sales_data
group by discount_flag;

#INSIGHTS: We are giving more no. of items with "no discount"


#or


select count(*) from sales_data where discount>0; # Items for discounts
select count(*) from sales_data where discount=0;   # Items -- no discount

