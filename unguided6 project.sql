/*
1. List the top 3 and bottom 3 makers for the fiscal years 2023 in
terms of the number of 2-wheelers ev sold.
*/

with ev_sales as 

(select maker, sum(electric_vehicles_sold) as total_ev_sold
from evmakers
where date between '2023-04-01' and '2024-03-31' and vehicle_category  = '2-Wheelers'
group by maker) ,

ranked_sales as

(select maker, total_ev_sold, 
rank() over(order by total_ev_sold desc ) as top_ev_makers,
rank() over(order by total_ev_sold asc  ) as bottom_ev_makers
from ev_sales)

select maker, total_ev_sold 
from ranked_sales
where top_ev_makers <=3 or bottom_ev_makers <= 3
order by top_ev_makers ,  bottom_ev_makers

/* 
2. Identify the top 5 states with the highest penetration rate in 2-wheeler
and 4-wheeler EV sales in FY 2023.
*/

(select state, 
sum(electric_vehicles_sold)*100.00 / sum(total_vehicles_sold) as penetration_rate
from evsales 
where vehicle_category = '2-Wheelers' and date between '2023-04-01' and '2024-03-31'
group by state
order by penetration_rate desc
limit 5)

union all 

(select state, 
sum(electric_vehicles_sold)*100.00 / sum(total_vehicles_sold) as penetration_rate
from evsales 
where vehicle_category = '4-Wheelers' and date between '2023-04-01' and '2024-03-31'
group by state
order by penetration_rate desc
limit 5)

/*
3. List the states with negative penetration (decline) in EV sales from 2022
to 2024?
*/

with cte as (
	select state,
	sum(electric_vehicles_sold)*100.00 / sum(total_vehicles_sold) as penetration_rate22 
	from evsales
	where date between '2022-01-01' and '2022-12-31'
	group by state
	) , 

cte1 as 

	(select state,
	sum(electric_vehicles_sold)*100.00 / sum(total_vehicles_sold) as penetration_rate24 
	from evsales
	where date between '2024-01-01' and '2024-12-31'
	group by state
	)

select  cte1.state ,  cte1.penetration_rate24, cte.penetration_rate22
from cte1 
join cte
on cte1.state = cte.state
where cte1.penetration_rate24 > cte.penetration_rate22
order by cte1.penetration_rate24 desc



/*
4. How do the EV sales and penetration rates in Delhi compare to
Karnataka for 2024?
*/

select state,  sum(electric_vehicles_sold) as ev_sales,
sum(electric_vehicles_sold) * 100.00 / sum (total_vehicles_sold) as penetration_rate
from evsales
where state = 'Karnataka' or state ='Delhi' and date BETWEEN '2024-01-01' AND '2024-12-31'
group by state


/*
5. List down the compounded annual growth rate (CAGR) in 4-wheeler
units for the top 5 makers from 2022 to 2024.
*/
with cte as
		(
		
		select maker, sum(electric_vehicles_sold) as starting_sales
		from evmakers
		where vehicle_category  = '4-Wheelers'  and  date between '2021-01-01' and '2021-12-31'
		group by maker
		order by starting_sales desc
		limit 5
		),
		
		cte1 as 		
		(		
		select maker, sum(electric_vehicles_sold) as ending_sales
		from evmakers
		where vehicle_category  = '4-Wheelers'  and  date between '2023-01-01' and '2023-12-31'
		group by maker
		order by ending_sales desc
		limit 5
		)
select cte.maker,
(((cte1.ending_sales::float / cte.starting_sales::float) ^ (1.0 / 2)) - 1) * 100 AS cagr
from cte
join cte1
on cte.maker = cte1.maker

/*
6. What are the peak and low season months for EV sales based on the
data from 2022 to 2024?
*/

(select   (select to_char(date, 'Month YYYY') as month_name),
sum(electric_vehicles_sold) as ev_sales  
from evsales

group by  date
having date between '2022-01-01' and '2025-01-1'
order by ev_sales desc
limit 1)

union all

(select   (select to_char(date, 'Month YYYY') as month_name),
sum(electric_vehicles_sold) as ev_sales  
from evsales

group by  date
having date between '2022-01-01' and '2025-01-1'
order by ev_sales asc
limit 1
)