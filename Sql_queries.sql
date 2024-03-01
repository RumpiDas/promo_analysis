/*Q1.
SELECT distinct dim_products.product_name, base_price
FROM dim_products
INNER JOIN fact_events
ON dim_products.product_code = fact_events.product_code
WHERE base_price > 500 AND promo_type = "BOGOF";  */

/*Q2.
SELECT city, count(*) as store_count
FROM dim_stores
GROUP BY city;  */

/*Q3.
SELECT 
    campaign_id,
    SUM(CASE 
            WHEN promo_type = '50% OFF' THEN (base_price * 0.5) * `quantity_sold(after_promo)`
            WHEN promo_type = 'BOGOF' THEN (base_price * `quantity_sold(after_promo)`)
            WHEN promo_type = '500 Cashback' THEN (base_price - 500) * `quantity_sold(after_promo)`
            WHEN promo_type = '25% OFF' THEN (base_price * 0.75) * `quantity_sold(after_promo)`
            WHEN promo_type = '33% OFF' THEN (base_price * 0.67) * `quantity_sold(after_promo)`
            ELSE base_price * `quantity_sold(after_promo)`
        END) / 1000000 AS total_revenue_after_promo,
    SUM(base_price * `quantity_sold(before_promo)`) / 1000000 AS total_revenue_before_promo
FROM 
    fact_events
GROUP BY 
    campaign_id; */

/*Q4. 
WITH CampaignSales AS (
    SELECT
        p.category,
        SUM(e.`quantity_sold(before_promo)`) AS total_quantity_sold_before_promo,
         SUM(CASE
            WHEN e.promo_type = 'BOGOF' THEN e.`quantity_sold(after_promo)` * 2
            ELSE e.`quantity_sold(after_promo)`
        END) AS adjusted_quantity_sold_after_promo
    FROM
        fact_events e
    INNER JOIN
        dim_products p ON e.product_code = p.product_code
    INNER JOIN
        dim_campaigns c ON e.campaign_id = c.campaign_id
    WHERE
        c.campaign_name = 'Diwali'
    GROUP BY
        p.category
)

SELECT
    cs.category,
    COALESCE(
        ROUND(((cs.adjusted_quantity_sold_after_promo - cs.total_quantity_sold_before_promo) / cs.total_quantity_sold_before_promo) * 100, 2),
        0
    ) AS isu_percentage,
    RANK() OVER (ORDER BY ((cs.adjusted_quantity_sold_after_promo - cs.total_quantity_sold_before_promo) / cs.adjusted_quantity_sold_after_promo) DESC) AS rank_order
FROM
    CampaignSales cs;
  */

/*Q5.
WITH CampaignTotals AS (
    SELECT
        dp.product_name,
        dp.category,
        SUM(fe.base_price * fe.`quantity_sold(before_promo)`) AS total_revenue_before_promo,
        SUM(CASE 
            WHEN fe.promo_type = '50% OFF' THEN (fe.base_price * 0.5) * fe.`quantity_sold(after_promo)`
            WHEN fe.promo_type = 'BOGOF' THEN fe.base_price * fe.`quantity_sold(after_promo)`
            WHEN fe.promo_type = '500 Cashback' THEN (fe.base_price - 500) * fe.`quantity_sold(after_promo)`
            WHEN fe.promo_type = '25% OFF' THEN (fe.base_price * 0.75) * fe.`quantity_sold(after_promo)`
            WHEN fe.promo_type = '33% OFF' THEN (fe.base_price * 0.67) * fe.`quantity_sold(after_promo)`
            ELSE 0
        END) AS total_revenue_after_promo
    FROM
        dim_products dp
    JOIN
        fact_events fe ON dp.product_code = fe.product_code
    GROUP BY
         dp.product_name, category
)

SELECT
    c.product_name,
    c.category,
    ROUND(((c.total_revenue_after_promo - c.total_revenue_before_promo) / c.total_revenue_before_promo) * 100, 2) AS ir_percentage
FROM
    CampaignTotals c
ORDER BY
    ir_percentage DESC
LIMIT
    5;
  */
