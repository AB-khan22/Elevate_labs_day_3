use project;
select distinct(payment_method) from Walmart;

select payment_method,count(*) as count from Walmart 
group by payment_Method order by payment_method;

select (count(distinct (branch))) from walmart;

-- Q1 Question: What are the different payment methods, and how many transactions and items were sold with each method?
create view paymethod_sales as
select payment_method,count(*) as no_of_transaction,sum(quantity) as number_of_quantity_sold from walmart group by payment_method order by payment_method;

-- Q2 Question: Which category received the highest average rating in each branch?
create view highestrating_each_category as
with rankcte as (select branch,category,avg(rating) as average_rating,
rank() over(partition by branch order by avg(rating)desc )as ranking from walmart group by branch,category ) 
select *  from rankcte where ranking =1;

-- Q3 Question: What is the busiest day of the week for each branch based on transaction volume?

alter table walmart modify date date;
desc walmart;
update walmart set date=str_to_date(date,'%d/%m/%y');
set sql_safe_updates=0;
select * from walmart;
desc walmart;
select max(transaction) ;
create view busiest_day_each_branchs as

with transcte as (select branch,dayname(date) as day_name,count(*) as transactions
,rank() over(partition by branch order by count(*) desc) as ranking from walmart group by branch,dayname(date))
select * from transcte where ranking=1;

-- Q4 Calculate Total Quantity Sold by Payment Method
-- Question: How many items were sold through each payment method?;
create view count_items_sold_by_each_paymethod as
select payment_method,count(quantity) as transaction 
from walmart group by payment_method order by transaction;

-- 5. Analyze Category Ratings by City
-- Question: What are the average, minimum, and maximum ratings for each category in each city?
create view average_min_max_ratings as
select city,category,min(rating),max(rating),avg(rating) 
from walmart group by city,category;

-- 6. Calculate Total Profit by Category
-- Question: What is the total profit for each category, ranked from highest to lowest?
create view profit_each_category as
select category,sum(total) as total_revenue,
sum(total* profit_margin) as profit from walmart group by category;

-- 7. Determine the Most Common Payment Method per Branch
-- Question: What is the most frequently used payment method in each branch?
create view most_frequently_used_method as 
with common_payment_cte as ( select branch,count(*) as total_trans,payment_method, rank() over(partition by branch order by  count(*) desc) as ranking 
from walmart group by branch,payment_method)
select * from common_payment_cte where ranking=1;

-- 8. Analyze Sales Shifts Throughout the Day
-- Question: How many transactions occur in each shift (Morning, Afternoon, Evening) across branches?
alter table walmart modify column time time;
select * from walmart;
create view transaction_in_shift
 as select branch,case
when hour(time) <12 then 'morning'
 when hour(time) between 12 and 17 then 'Afternoon'
else 'evening '
end day_time,count(*) from walmart
group by branch,day_time order by branch,count(*) desc;

-- 9. Identify Branches with Highest Revenue Decline Year-Over-Year
 -- Question: Which branches experienced the largest decrease in revenue compared to the previous year?
create view revenue_decrease_between_past_two_years as
with revenue2022 as(select branch,sum(total) as revenue  from walmart
 where year(date) =2022 group by branch),
 revenue2023 as (select branch,sum(total)as revenue from walmart where year(date)=2023 
 group by branch)
 select ls.branch as branch ,ls.revenue as previous_revenue,cs.revenue as current_revenue,
 round(((ls.revenue-cs.revenue)/ls.revenue *100) ,2) as revenue_decrease_ration from revenue2022 as ls join revenue2023 as cs 
 on ls.branch=cs.branch where ls.revenue>cs.revenue order by revenue_decrease_ration desc limit 5 ;
 