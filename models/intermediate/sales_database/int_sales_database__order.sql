WITH
  order_item_grouped_by_order AS (
    SELECT
      order_id,
      SUM(total_order_item_amount) AS total_order_amount,
      SUM(item_quantity) AS total_items,
      COUNT(DISTINCT product_id) AS total_distinct_items
    FROM {{ ref('stg_sales_database__order_item') }}
    GROUP BY order_id
  ),
  feedback_grouped_by_order AS (
    SELECT
      order_id,
      AVG(feedback_score) AS average_feedback_score
    FROM {{ ref('stg_sales_database__feedback') }}
    GROUP BY order_id
  )
SELECT
  o.order_id,
  o.user_id,
  o.order_status,
  o.order_created_at,
  o.order_approved_at,
  u.user_city,
  u.user_state,
  f.average_feedback_score,
  COALESCE(oi.total_order_amount, 0) AS total_order_amount,
  COALESCE(oi.total_items, 0) AS total_items,
  COALESCE(oi.total_distinct_items, 0) AS total_distinct_items
FROM {{ ref('stg_sales_database__order') }} AS o
LEFT JOIN order_item_grouped_by_order AS oi
  ON o.order_id = oi.order_id
LEFT JOIN feedback_grouped_by_order AS f
  ON o.order_id = f.order_id
LEFT JOIN {{ ref('stg_sales_database__user') }} AS u
  ON o.user_id = u.user_id
