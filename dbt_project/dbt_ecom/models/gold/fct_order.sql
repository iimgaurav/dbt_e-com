{{config(materialized='table') }}

select 
     transaction_id,
     order_date,
     customer_id,
     product_id,
     quantity,
     price,
     quantity * price as total_amount
from {{ ref('sl_ecommerce_sales') }}