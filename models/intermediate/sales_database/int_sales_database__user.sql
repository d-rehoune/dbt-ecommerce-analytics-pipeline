WITH
  orders_summary AS (
    SELECT
      user_id,
      user_city,
      user_state,
      SUM(total_order_amount) AS total_amount_spent,
      SUM(total_items) AS total_items,
      SUM(total_distinct_items) AS total_distinct_items,
      COUNT(DISTINCT order_id) AS total_orders
    FROM
      {{ ref('int_sales_database__order') }}
    GROUP BY user_id, user_city, user_state
  )

SELECT
  os.user_id,
  os.user_city,
  os.user_state,
  os.total_amount_spent,
  os.total_items,
  os.total_distinct_items,
  os.total_orders,
  p.favorite_product_id
FROM orders_summary AS os
LEFT JOIN
  {{ ref('int_sales_database__user_favorite_product') }} AS p
  ON
    os.user_id = p.user_id

