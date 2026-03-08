{{config(materialized='table') }}

select distinct 
     customer_id, 
     customer_name,
     country
from {{ ref('sl_ecommerce_sales') }}