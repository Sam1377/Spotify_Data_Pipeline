-- ============================================================
--  Athena Analytics Queries — Spotify Pipeline
--  Table: spotify_spotify_pipeline_transformed  (Glue catalog)
--  Run these in the Athena query editor (ap-south-1)
-- ============================================================

-- 1. Total track count
SELECT COUNT(*) AS total_tracks
FROM spotify_spotify_pipeline_transformed;

-- 2. Top 10 artists by number of tracks
SELECT   artist,
         COUNT(*) AS total_tracks
FROM     spotify_spotify_pipeline_transformed
GROUP BY artist
ORDER BY total_tracks DESC
LIMIT    10;

-- 3. Top 10 most popular tracks
SELECT   track_name,
         artist,
         popularity
FROM     spotify_spotify_pipeline_transformed
ORDER BY popularity DESC
LIMIT    10;

-- 4. Average track duration (minutes) per artist — top 10
SELECT   artist,
         ROUND(AVG(duration_ms) / 60000.0, 2) AS avg_duration_min
FROM     spotify_spotify_pipeline_transformed
GROUP BY artist
ORDER BY avg_duration_min DESC
LIMIT    10;

-- 5. Track count by release year
SELECT   SUBSTR(release_date, 1, 4)  AS release_year,
         COUNT(*)                     AS tracks
FROM     spotify_spotify_pipeline_transformed
WHERE    release_date IS NOT NULL
GROUP BY SUBSTR(release_date, 1, 4)
ORDER BY release_year DESC;

-- 6. Track count by release date (full date)
SELECT   release_date,
         COUNT(*) AS tracks
FROM     spotify_spotify_pipeline_transformed
GROUP BY release_date
ORDER BY release_date DESC;

-- 7. Longest tracks
SELECT   track_name,
         artist,
         ROUND(duration_ms / 60000.0, 2) AS duration_min
FROM     spotify_spotify_pipeline_transformed
ORDER BY duration_ms DESC
LIMIT    10;

-- 8. All tracks (preview)
SELECT *
FROM   spotify_spotify_pipeline_transformed
LIMIT  50;
