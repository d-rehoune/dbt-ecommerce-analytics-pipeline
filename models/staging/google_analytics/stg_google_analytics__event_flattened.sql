SELECT
  event_date,
  event_name,
  user_pseudo_id,
  user_first_touch_timestamp,
  device.web_info.browser,
  traffic_source.source,
  traffic_source.name,
  TIMESTAMP_MICROS(event_timestamp) AS event_timestamp,
  (SELECT value.int_value FROM UNNEST(e.event_params) AS ep WHERE ep.key = 'ga_session_id') AS ga_session_id,
  (SELECT value.string_value FROM UNNEST(e.event_params) AS ep WHERE ep.key = 'page_title') AS page_title,
  (SELECT value.string_value FROM UNNEST(e.event_params) AS ep WHERE ep.key = 'page_location') AS page_location
FROM {{ source('google_analytics_4', 'events_20210131') }} AS e

