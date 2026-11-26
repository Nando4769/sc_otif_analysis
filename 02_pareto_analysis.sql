-- shipping mode sla gap & revenue gap 

select 
shipping_mode, 
COUNT (distinct(order_id)) as unique_orders, 
ROUND(AVG(scheduled_shipping_days),2) as avg_scheduled_days, 
ROUND(AVG(actual_shipping_days),2) as avg_actual_days,
ROUND(AVG(delay_days),2) as avg_delay_days,
ROUND(100*AVG(is_on_time),2) as otd_pct,
ROUND(SUM(late_sales_exposure)::NUMERIC,2) as total_late_sales_exposure

from otif_project.vw_delivery_performance

group by shipping_mode
order by otd_pct asc ; 


-- Pareto 80/20 bottleneck 
with slice_summary as (
		select 
		order_region,
		
		COUNT(distinct
		(
		case 
			when is_on_time = 0 then order_id
		end)) as late_orders, 
		
		round(sum(late_sales_exposure)::numeric,2) as total_late_sales_exposure
	
	from otif_project.vw_delivery_performance
	group by order_region
	)

	select 
		* , 
		dense_rank() over (order by late_orders desc) as region_rank,
		
		round((sum(late_orders) over (order by late_orders desc) / sum(late_orders) over ()) *  100,2) as cumulative_pct
	
	from slice_summary 
	order by late_orders desc ; 
	