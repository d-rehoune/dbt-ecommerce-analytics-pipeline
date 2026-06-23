SELECT 
    state,
    account_manager
FROM {{ source('google_sheets', 'mapping' ) }}