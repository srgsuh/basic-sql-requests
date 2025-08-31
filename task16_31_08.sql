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

