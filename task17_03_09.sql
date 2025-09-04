-- 1. Top 5 longest tracks
select	tr.track_id as "Track ID", 
		tr.name as "Track name",
		al.title as "Album title", 
		to_char(make_interval(secs => round(tr.milliseconds/1000)), 'MI:SS:') || 
		to_char(tr.milliseconds % 1000, 'FM009') as "Time"
from track tr
left join album al on tr.album_id = al.album_id
order by tr.milliseconds desc
limit 5;

-- ???? 4. All billing countries having maximal number of invoices
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