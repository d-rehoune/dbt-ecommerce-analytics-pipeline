WITH
  order_item_grouped_by_order AS (
    SELECT
      order_id,
      SUM(total_order_item_amount) AS total_order_amount,
      sum(item_quantity) AS total_items,
      COUNT(DISTINCT product_id) AS total_distinct_items
    FROM {{ ref('stg_sales_database__order_item') }}
    GROUP BY order_id
  ),
  feedback_grouped_by_order AS (
    SELECT
      order_id,
      avg(feedback_score) AS average_feedback_score
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
  f.average_feedback_score,
  oi.total_order_amount,
  oi.total_items,
  oi.total_distinct_items
FROM {{ ref('stg_sales_database__order') }} AS o
LEFT JOIN order_item_grouped_by_order AS oi
  ON o.order_id = oi.order_id
LEFT JOIN feedback_grouped_by_order AS f
  ON f.order_id = o.order_id
LEFT JOIN {{ ref('stg_sales_database__user') }} AS u
  ON u.user_id = o.user_id
