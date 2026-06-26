WITH aggregated_session_date AS (

SELECT 
  user_pseudo_id,
  ga_session_id,
  CONCAT(ga_session_id, '_', user_pseudo_id) AS unique_session_id,
  MIN(event_timestamp) AS session_start_time,
  MAX(event_timestamp) AS session_end_time,
  SUM(CASE WHEN event_name = 'page_view' THEN 1 ELSE 0 END) AS pages_viewed,
  COUNT(*) AS event_count,
  MAX(browser) AS browser_used,
  MAX(source) AS traffic_source,
  MAX(name) AS traffic_name
FROM {{ ref('stg_google_analytics__event_flattened') }}
GROUP BY user_pseudo_id, ga_session_id
)

SELECT 
  unique_session_id,
  user_pseudo_id,
  ga_session_id,
  session_start_time,
  session_end_time,
  pages_viewed,
  event_count,
  browser_used,
  traffic_source,
  traffic_name,
  TIMESTAMP_DIFF(session_end_time, session_start_time, SECOND) AS session_duration_seconds
FROM aggregated_session_date 




