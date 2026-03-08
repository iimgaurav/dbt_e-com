{{ config(materialized='view') }}

select *
from  {{ ref('ecommerce_sales') }} 