-- Tracks never sold ordered by artist’s name and track’s name
select	tr.track_id "Track ID",
		tr.name "Track name",
		g.name "Genre name",
		art.name "Artist name"
from track tr
join album al on tr.album_id = al.album_id
join artist art on art.artist_id = al.artist_id
join genre g on tr.genre_id = g.genre_id 
where not exists (select 1 from invoice_line il where il.track_id = tr.track_id)
order by art.name, tr.name;

-- Top 10 tracks by revenue ordered by revenue in descending order and by artist name and by track name
select 	track_id "Track ID",
		track_name "Track name",
		artist_name "Artist"
from (
	select	tr.track_id,
			tr.name track_name,
			art.name artist_name,
			sum(il.quantity * il.unit_price) track_revenue
	from track tr
	join invoice_line il on tr.track_id = il.track_id
	join album al on tr.album_id = al.album_id
	join artist art on art.artist_id = al.artist_id
	group by tr.track_id, art.artist_id
) agg_data
order by track_revenue desc, artist_name, track_name
limit 10;

-- Top 5 genres by revenue ordered by revenue in descending order and by genre name
select g.genre_id, g.name, sum(il.quantity * il.unit_price) genre_revenue
from track tr
join genre g on tr.genre_id = g.genre_id
join invoice_line il on tr.track_id = il.track_id
group by g.genre_id, g.name
order by genre_revenue desc, g.name
limit 5;