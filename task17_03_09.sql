-- 1. Top 5 longest tracks
select	tr.track_id as "Track ID", 
		tr.name as "Track name",
		al.title as "Album title",
		tr.milliseconds,
		to_char(make_interval(secs => tr.milliseconds/1000.0), 'HH24:MI:SS.MS') as "Time"
from track tr
left join album al on tr.album_id = al.album_id
order by tr.milliseconds desc
limit 5;

-- 2. All genres providing revenue of top 3 values
with ranked_genres as(
    select	g.name as genre_name,
              sum(il.quantity * il.unit_price) as revenue,
              dense_rank() over(order by sum(il.quantity * il.unit_price) desc) rnk
    from genre g
             join track tr on tr.genre_id = g.genre_id
             join invoice_line il on il.track_id = tr.track_id
    group by g.name
)
select * from ranked_genres
where rnk <= 3;

-- 3. All customers whose revenue is within top 3 positions
select	customer_id as "Customer Id",
		full_name as "Customer full name",
		revenue as "Revenue value"
from (
	select	c.customer_id,
			concat(c.first_name, ' ', c.last_name) full_name,
			sum(i.total) revenue,
			rank() over (order by sum(i.total) desc) rnk
	from customer c
	join invoice i on i.customer_id = c.customer_id
	group by c.customer_id, full_name
) cust_revenue
where rnk <= 3;


-- 4. All billing countries having maximal number of invoices
with invoices_by_country as (
    select i.billing_country country, count(1) num_of_invoices
    from invoice i
    group by i.billing_country
), max_invoices as (
	select max(num_of_invoices) max_invoices from invoices_by_country
)
select ibc.*
from invoices_by_country ibc
cross join max_invoices mi
where ibc.num_of_invoices = mi.max_invoices
order by country;

-- 5. All employees whose supported customers provide 80% of the total revenue according to Pareto rule
explain
with empl_revenue as (
	select	concat(e.first_name, ' ', e.last_name) employee_name,
			sum(i.total) revenue
	from employee e
	join customer c on c.support_rep_id = e.employee_id
	join invoice i on i.customer_id = c.customer_id
	group by employee_name
), empl_revenue_running as(
	select	er.*,
			sum( revenue ) over (order by revenue desc, employee_name) running_total,
			sum( revenue ) over () total
	from empl_revenue er
), empl_revenue_lag as (
	select	err.*, lag(running_total, 1) over (order by revenue desc, employee_name) total_lag
	from empl_revenue_running err
)
select employee_name, revenue
from empl_revenue_lag erl
where erl.total_lag is null or erl.total_lag < 0.8 * erl.total
order by revenue desc, employee_name;
