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




