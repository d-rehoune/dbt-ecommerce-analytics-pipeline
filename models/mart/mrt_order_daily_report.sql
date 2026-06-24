WITH
  agregated_order AS (
    SELECT
      DATE(order_created_at) AS order_date,
      user_state AS state,
      COUNT(DISTINCT order_id) AS total_orders,
      AVG(total_items) AS average_item_per_order,
      AVG(average_feedback_score) AS average_feedback_score,
      AVG(total_order_amount) AS average_amount_spent_per_order
    FROM {{ ref('int_sales_database__order') }}
    GROUP BY
      order_date, user_state
  )
SELECT
  orders.order_date,
  orders.state,
  mapping.account_manager,
  orders.total_orders,
  orders.average_item_per_order,
  orders.average_feedback_score,
  orders.average_amount_spent_per_order
FROM agregated_order AS orders
LEFT JOIN {{ ref('stg_google_sheets__account_manager_region_mapping') }} AS mapping
  ON orders.state = mapping.state
