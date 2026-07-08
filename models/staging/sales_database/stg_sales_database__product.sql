SELECT
  product_id,
  CAST(product_name_lenght AS int64) AS product_name_lenght,
  CAST(product_description_lenght AS int64) AS product_description_lenght,
  CAST(product_photos_qty AS int64) AS product_photos_qty,
  CAST(product_weight_g AS int64) AS product_weight_g,
  CAST(product_length_cm AS int64) AS product_length_cm,
  CAST(product_height_cm AS int64) AS product_height_cm,
  CAST(product_width_cm AS int64) AS product_width_cm,
  COALESCE(product_category, 'other') AS product_category,
  {{ get_product_volume('product_length_cm','product_height_cm','product_width_cm') }} AS product_volume_cm3
FROM {{ source('sales_database', 'product') }}