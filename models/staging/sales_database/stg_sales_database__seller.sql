SELECT
    seller_id,
    seller_zip_code,
    seller_city,
    seller_state
FROM {{ source('sales_database', 'seller') }}