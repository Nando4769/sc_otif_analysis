
-- check the date/time format 
SELECT "order date (DateOrders)" 
FROM otif_project.datacosupplychaindataset LIMIT 5;

--create vw_delivery_performance to run delivery checks
create or replace view otif_project.vw_delivery_performance as 
with cleaned_orders as (
	select -- rename messy cv headers into clean snake_case 
		"Order Id" as order_id, 
		TO_TIMESTAMP("order date (DateOrders)", 'MM/DD/YYYY HH24:MI') as order_date,
		"Shipping Mode" as shipping_mode,
		"Order Item Id" as order_item_id,
		"Order Status" as order_status,
		"Delivery Status" as delivery_status,
		"Order Region" as order_region,
		"Category Name" as category_name,
		"Days for shipping (real)" as actual_shipping_days,
		"Days for shipment (scheduled)" as scheduled_shipping_days,
		"Order Item Quantity" as order_item_quantity,
		"Sales" as sales,
		"Order Profit Per Order" as order_profit,
		
-- calculate core operaitonal flags 
		case 
			when "Days for shipping (real)" <= "Days for shipment (scheduled)" then 1
			else 0
		end as is_on_time,
		
		("Days for shipping (real)" - "Days for shipment (scheduled)")
		as delay_days ,
		
		case 
			when "Days for shipping (real)" > "Days for shipment (scheduled)" then "Sales"
			else 0
		end as late_sales_exposure
		
		

	from otif_project.datacosupplychaindataset
		where "Order Status" not in ('CANCELED','SUSPECTED_FRAUD')
		) 	
select *
from cleaned_orders ; 



select 
vdp.shipping_mode, 
ROUND(AVG(case when vdp.delivery_status in ('Advance shipping', 'Shipping on time') then 1
else 0
end)*100,2) as calc_otd_pct,

ROUND(AVG(vdp.is_on_time) * 100, 2) as raw_status_otd_pct

from vw_delivery_performance vdp
group by vdp.shipping_mode 
; 


		
	
