
--Number of tracks in each playlist.
SELECT playlists.PlaylistId, playlists.Name, count(tracks.trackId) as NumOfTracks
FROM playlists
JOIN playlist_track
	ON playlists.PlaylistId = playlist_track.PlaylistId
JOIN tracks
	ON playlist_track.TrackId = tracks.TrackId
GROUP BY playlists.PlaylistId;

--Which tracks appeared in the most playlist?
SELECT 
	 t.trackId,
	 t.name as 'Track Name',
	 count(p.PlaylistId) as 'Number Of Playlists'
FROM playlist_track p 
JOIN tracks t
	ON p.TrackId = t.TrackId
GROUP BY t.trackid
ORDER BY 1 DESC, 3
LIMIT 50;

--Number of tracks and total per invoice.
SELECT invoices.InvoiceId, count(tracks.TrackId) as 'Tracks Purchased',invoices.Total
FROM invoices
JOIN invoice_items
	ON invoices.InvoiceId = invoice_items.InvoiceId
JOIN tracks
	ON invoice_items.TrackId = tracks.TrackId
GROUP BY invoices.InvoiceId;

--Which track generated the most revenue?
SELECT 
	tracks.name, 
	ROUND(SUM(invoice_items.UnitPrice),2) as 'Total Revenue', 
	COUNT(invoice_items.quantity) as 'Times Purchased'
FROM invoice_items
JOIN tracks
	ON invoice_items.TrackId = tracks.TrackId 
GROUP BY tracks.TrackId
ORDER BY 2 DESC
LIMIT 10;

--Which album generated the most revenue?
SELECT 
	albums.Title, 
	SUM(invoice_items.UnitPrice) as 'Total Revenue', 
	COUNT(invoice_items.quantity) as 'Times Purchased'
FROM invoice_items
JOIN tracks
	ON invoice_items.TrackId = tracks.TrackId
JOIN albums
	ON tracks.AlbumId = albums.AlbumId
GROUP BY tracks.AlbumId
ORDER BY 2 DESC
LIMIT 10;

--Which genre generated the most revenue?
SELECT 
	genres.name, 
	ROUND(SUM(invoice_items.UnitPrice),2) as 'Total Revenue', 
	COUNT(invoice_items.quantity) as 'Times Purchased'
FROM invoice_items
JOIN tracks
	ON invoice_items.TrackId = tracks.TrackId
JOIN genres
	ON tracks.GenreId = genres.GenreId
GROUP BY genres.name
ORDER BY 2 DESC
LIMIT 10;

--Which country generated the most revenue?
SELECT 	
	BillingCountry, 
	SUM(total) as 'Total'
FROM invoices
GROUP BY BillingCountry
ORDER BY 2 DESC;

--What percent of total revenue does each country make up?
SELECT 
	BillingCountry, 
	ROUND(SUM(total),2) as 'Total Revenue',
	ROUND(((SUM(total)/(SELECT SUM(total) FROM invoices))*100),1) as 'Percentage of Total'
FROM invoices
GROUP BY BillingCountry
ORDER BY 2 DESC;

--How many customers did each employee support?
SELECT 
	e.FirstName, 
	e.LastName, 
	COUNT(c.CustomerId) as 'Customers Supported'
FROM customers as c
JOIN employees as e
	ON c.SupportRepId = e.EmployeeId
GROUP BY e.EmployeeId

--What is the average revenue for each sale?
SELECT ROUND(AVG(total),2) as 'Average Revenue'
FROM invoices

--What is the total revenue produced by each employee?
SELECT 
	emp.EmployeeId, 
	emp.FirstName, 
	emp.LastName, 
	ROUND(SUM(inv.total),2) as 'Total Revenue'
FROM employees emp
JOIN customers cus 
	ON emp.EmployeeId = cus.SupportRepId
JOIN invoices inv 
	ON cus.CustomerId = inv.CustomerId
GROUP BY emp.EmployeeId

--What is the average sale price produced by each employee?
SELECT 
	emp.EmployeeId, 
	emp.FirstName, 
	emp.LastName, 
	ROUND(AVG(inv.total),2) as 'Average Sale Price'
FROM employees emp
JOIN customers cus 
	ON emp.EmployeeId = cus.SupportRepId
JOIN invoices inv 
	ON cus.CustomerId = inv.CustomerId
GROUP BY emp.EmployeeId

--Do longer or shorter length albums tend to generate more revenue?
WITH album_length AS(
SELECT 
	tracks.albumId AS 'AlbumId',
	COUNT(tracks.TrackId) AS 'TrackCount'
FROM tracks
GROUP BY 1
ORDER BY 2)

SELECT 
	album_length.TrackCount as 'Number of Tracks',
	COUNT(DISTINCT album_length.AlbumId) as 'Number of Albums',
	ROUND(SUM(Invoice_items.UnitPrice),2) as 'Total Revenue',
	ROUND(SUM(Invoice_items.UnitPrice)/COUNT(DISTINCT album_length.AlbumId),2) as 'Average Revenue'
FROM tracks
JOIN album_length
	ON tracks.AlbumId = album_length.AlbumId
JOIN invoice_items
	ON  tracks.TrackId = invoice_items.TrackId
GROUP BY 1;

--How many tracks are in each playlist?
SELECT PlaylistId, COUNT(TrackId) as 'Number of Tracks'
FROM playlist_track
GROUP BY PlaylistId

--Is the number of times a track appears in any playlist a good indicator of sales?
WITH a_count AS(
	SELECT playlist_track.TrackId as 'TrackId', 
		COUNT(playlist_track.PlaylistId) as 'pl_count'
	FROM playlist_track
	GROUP BY 1
)

SELECT 
	a_count.pl_count as 'Appearance Count', 
	ROUND(SUM(invoice_items.UnitPrice),2) as 'Total Revenue'
FROM a_count
JOIN invoice_items
	ON a_count.TrackId = invoice_items.TrackId
GROUP BY 1;

--How many sales were there each year?
SELECT 
	strftime('%Y', InvoiceDate) as 'Year', 
	COUNT(*) as 'Total Sales'
FROM invoices
GROUP BY 1;

--How much revenue is generated each year?
SELECT 
	strftime('%Y', InvoiceDate) as 'Year', 
	COUNT(*) as 'Total Sales',
	SUM(Total) as 'Total Revenue'
FROM invoices
GROUP BY 1;

--How much revenue is generated each year?
--Using one WITH clause as two temporary tables
WITH yr AS(
	SELECT	
		(CAST(strftime('%Y', InvoiceDate) as INTEGER) - 1) as 'prev_yr',
		CAST(strftime('%Y', InvoiceDate) as INTEGER) as 'cur_yr',
		SUM(total) as 'revenue'
	FROM invoices
	GROUP BY 1
)

SELECT 
	prev.cur_yr 'Previous Year',
	prev.revenue as 'Previoue Revenue',
	cur.cur_yr 'Current year',
	cur.revenue as 'Current Revenue',
	ROUND(((cur.revenue-prev.revenue)/prev.revenue)*100,1) as 'Percent Change'
FROM yr cur 
JOIN yr prev
	ON cur.prev_yr = prev.cur_yr;



