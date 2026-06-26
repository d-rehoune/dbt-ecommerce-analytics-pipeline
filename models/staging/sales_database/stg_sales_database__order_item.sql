SELECT
  order_id,
  product_id,
  seller_id,
  price AS unit_price,
  shipping_cost,
  quantity AS item_quantity,
  CONCAT(order_id, '_', product_id) AS order_item_id,
  DATETIME(pickup_limit_date, 'Europe/Paris') AS picked_up_limited_at,
  (price * quantity) + shipping_cost AS total_order_item_amount
FROM {{ source('sales_database', 'order_item') }}