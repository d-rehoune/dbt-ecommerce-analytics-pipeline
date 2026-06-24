SELECT
  event_date,
  event_name,
  TIMESTAMP_MICROS(event_timestamp) AS event_timestamp,
  (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id') AS ga_session_id,
  (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'page_title') AS page_title,
  (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'page_location') AS page_location,
  user_pseudo_id,
  user_first_touch_timestamp,
  device.web_info.browser,
  traffic_source.source,
  traffic_source.name
FROM {{ source('google_analytics_4', 'events_20210131') }}

