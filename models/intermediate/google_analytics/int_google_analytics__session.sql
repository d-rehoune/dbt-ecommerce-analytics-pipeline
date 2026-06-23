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
  CONCAT(user_pseudo_id, '_', ga_session_id) AS unique_session_id,
  user_pseudo_id,
  ga_session_id,
  session_start_time,
  session_end_time,
  TIMESTAMP_DIFF(session_end_time, session_start_time, second) AS session_duration_seconds,
  pages_viewed,
  event_count,
  browser_used,
  traffic_source,
  traffic_name
FROM aggregated_session_date 




