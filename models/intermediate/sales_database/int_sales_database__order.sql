WITH
  order_item_grouped_by_order AS (
    SELECT
        order_id,
        user_id,
        order_status,
        order_created_at,
        order_approved_at,
        SUM(total_order_item_amount) AS total_order_amount,
        SUM(item_quantity) AS total_items,
        COUNT(DISTINCT product_id) AS total_distinct_items
    FROM {{ ref('int_sales_database__order_item') }}
    GROUP BY 
        order_id,
        user_id,
        order_status,
        order_created_at,
        order_approved_at
  ),
  feedback_grouped_by_order AS (
    SELECT
      order_id,
      AVG(feedback_score) AS average_feedback_score
    FROM {{ ref('stg_sales_database__feedback') }}
    GROUP BY order_id
  )
SELECT
  oi.order_id,
  oi.user_id,
  oi.order_status,
  oi.order_created_at,
  oi.order_approved_at,
  u.user_city,
  u.user_state,
  f.average_feedback_score,
  COALESCE(oi.total_order_amount, 0) AS total_order_amount,
  COALESCE(oi.total_items, 0) AS total_items,
  COALESCE(oi.total_distinct_items, 0) AS total_distinct_items
FROM order_item_grouped_by_order AS oi
LEFT JOIN feedback_grouped_by_order AS f
  ON oi.order_id = f.order_id
LEFT JOIN {{ ref('stg_sales_database__user') }} AS u
  ON oi.user_id = u.user_id
