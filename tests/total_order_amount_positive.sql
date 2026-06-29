SELECT
    order_id,
    sum(total_order_item_amount) AS total_amount
FROM {{ ref('stg_sales_database__order_item') }}
GROUP BY order_id
HAVING total_amount < 0