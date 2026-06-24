WITH
  orders_summary AS (
    SELECT
      o.user_id,
      SUM(total_order_item_amount) AS total_amount_spent,
      SUM(oi.item_quantity) AS total_items,
      COUNT(DISTINCT product_id) AS total_distinct_items,
      COUNT(DISTINCT o.order_id) AS total_orders
    FROM
      {{ref('stg_sales_database__order_item')}} oi
    INNER JOIN
      {{ ref('stg_sales_database__order') }} o
      ON oi.order_id = o.order_id
    GROUP BY
      o.user_id
  ),
  product_summary AS (
    SELECT
      o.user_id,
      oi.product_id,
      ROW_NUMBER()
        OVER (
          PARTITION BY o.user_id
          ORDER BY SUM(item_quantity) DESC
        ) AS rn
    FROM
      {{ref('stg_sales_database__order_item')}} oi
    INNER JOIN
      {{ref('stg_sales_database__order')}} o
      ON oi.order_id = o.order_id
    GROUP BY
      o.user_id,
      oi.product_id
  )
SELECT
  u.user_id,
  u.user_city,
  u.user_state,
  o.total_amount_spent,
  o.total_items,
  o.total_distinct_items,
  o.total_orders,
  p.product_id AS favorite_product_id
FROM {{ ref('stg_sales_database__user') }} u
LEFT JOIN 
  orders_summary o
  ON u.user_id = o.user_id
LEFT JOIN
  product_summary p
  ON
    o.user_id = p.user_id
    AND p.rn = 1
