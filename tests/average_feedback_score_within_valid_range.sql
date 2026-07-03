SELECT 
    order_date,
    state,
    account_manager,
    total_orders,
    average_item_per_order,
    average_feedback_score,
    average_amount_spent_per_order
FROM {{ ref('mrt_order_daily_report') }}
WHERE average_feedback_score NOT BETWEEN 1 AND 5
  AND average_feedback_score IS NOT NULL