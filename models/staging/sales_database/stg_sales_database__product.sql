SELECT
  product_id,
  COALESCE(product_category, 'other') AS product_category,
  CAST(product_name_lenght AS INT) product_name_lenght,
  CAST(product_description_lenght AS INT) AS product_description_lenght,
  CAST(product_photos_qty AS INT) AS product_photos_qty,
  CAST(product_weight_g AS INT) AS product_weight_g,
  CAST(product_length_cm AS INT) AS product_length_cm,
  CAST(product_height_cm AS INT) AS product_height_cm,
  CAST(product_width_cm AS INT) AS product_width_cm
FROM {{ source('sales_database', 'product') }}