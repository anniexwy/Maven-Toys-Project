----First, I created a schema called "mexicotoysales" to store the tables for analysis. Four tables are included in this schema: 
----inventory (incl. store id for each stores, product id for each products & stock on hand for each stores, divided by products),
----products (incl. product id for each stores, product name, product category, cost of each type of product & price of each type of product)
----sales (incl. sale id for each purchase record, dates for the purchases, store id for each stores, product id for each stores & units sold for each purchase)
----stores (incl. store id for each stores, store name for each stores, city where the stores loacated in, type of store location & the date the stores opened)

----Then, I conducted the analysis below


/*Revenue, Profit, Profit Margin, Number of Purchases & Units Sold in General*/
SELECT SUM(pro.product_price*sa.units) revenue,
	   SUM((pro.product_price-pro.product_cost)*sa.units) profit,
	   ROUND(SUM((pro.product_price-pro.product_cost)*sa.units)/SUM(pro.product_price*sa.units),4) profit_margin,
	   COUNT(sa.sale_id) num_purchases,
	   SUM(sa.units) units_sold
FROM mexicotoysales.sales sa        -- In PostgreSQL, you have to identify which schema the table belongs to when pulling data from the tables
LEFT JOIN mexicotoysales.products pro
ON sa.product_id=pro.product_id
--Revenue: $14.44M, Profit: $4.01M, Profit Margin: 27.79%, Number of Purchases: 829K, Units Sold: 1.09M



/*Sales Analysis from Different Aspects*/
---Find the city with the highest revenue, margin, profit margin, number of purchases and units sold
SELECT st.store_city,
       SUM(pro.product_price*sa.units) revenue,
	   SUM((pro.product_price-pro.product_cost)*sa.units) profit,
	   ROUND(SUM((pro.product_price-pro.product_cost)*sa.units)/SUM(pro.product_price*sa.units),4) profit_margin,
	   COUNT(sa.sale_id) num_purchases,
	   SUM(sa.units) units_sold
FROM mexicotoysales.sales sa
LEFT JOIN mexicotoysales.products pro
ON sa.product_id=pro.product_id
LEFT JOIN mexicotoysales.stores st
ON sa.store_id=st.store_id
GROUP BY 1
ORDER BY 2 DESC;
/*ORDER BY 3 DESC;
ORDER BY 4 DESC;
ORDER BY 5 DESC;
ORDER BY 6 DESC;*/
--Stores in Cuidad de Mexico obtain the highest revenue, profit, number of purchases & units sold
--Stores in Morelia has the highest profit margin than stores in other areas

---Find the type of stores loctaion with the highest revenue, margin, profit margin, number of purchases and units sold
WITH product_sales AS(
	 SELECT st.store_location type_of_location,
	        pro.product_price price,
	        pro.product_cost p_cost,
	        sa.units,
	        sa.sale_id
     FROM mexicotoysales.sales sa
     LEFT JOIN mexicotoysales.products pro
     ON sa.product_id=pro.product_id
     LEFT JOIN mexicotoysales.stores st
     ON sa.store_id=st.store_id)

SELECT type_of_location,
	   SUM(price*units) revenue,
	   SUM((price-p_cost)*units) profit,
	   ROUND(SUM((price-p_cost)*units)/SUM(price*units),4) profit_margin,
	   COUNT(sale_id) num_purchases,
	   SUM(units) units_sold
FROM product_sales
GROUP BY 1
ORDER BY 2 DESC;
--Stores in downtown area have the highest revenue, profit, number of purchases and units sold in total
--Stores in airports have the highest profit margin in total

---Find the product categories with the biggest revenue, margin, profit margin, number of purchases and units sold
SELECT pro.product_category,
       SUM(pro.product_price*sa.units) revenue,
	   SUM((pro.product_price-pro.product_cost)*sa.units) profit,
	   ROUND(SUM((pro.product_price-pro.product_cost)*sa.units)/SUM(pro.product_price*sa.units),4) profit_margin,
	   COUNT(sa.sale_id) num_purchases,
	   SUM(sa.units) units_sold
FROM mexicotoysales.sales sa
LEFT JOIN mexicotoysales.products pro
ON sa.product_id=pro.product_id
GROUP BY 1
ORDER BY 2 DESC;
/*ORDER BY 3 DESC;
ORDER BY 4 DESC;
ORDER BY 5 DESC;
ORDER BY 6 DESC;*/
--Toys has the highest revenue, profit and number of purchases among all the four categories
--Arts & Crafts has the second highest revenue, yet has the third highest profit, and has the highest units sold.
--Electronics has much more higher profit margin than the other four categories

---Find the top 5 products which gains most of the revenue
SELECT pro.product_name,
       pro.product_category,
       SUM(pro.product_price*sa.units) revenue
FROM mexicotoysales.sales sa
LEFT JOIN mexicotoysales.products pro
ON sa.product_id=pro.product_id
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 5;
--Top 5 products with highest revenue: Lego Bricks(Toys), Colorbuds(Electronics), Magic Sand(Art & Crafts), Action Figure(Toys) & Rubik's Cube (Games)

---Top 5 stores which gain the highest revenues
WITH ps AS(
	 SELECT st.store_name,
	        st.store_location type_of_location,        
	        pro.product_price price,
	        pro.product_cost p_cost,
	        sa.units,
	        sa.sale_id
     FROM mexicotoysales.sales sa
     LEFT JOIN mexicotoysales.products pro
     ON sa.product_id=pro.product_id
     LEFT JOIN mexicotoysales.stores st
     ON sa.store_id=st.store_id)

SELECT store_name,
       type_of_location,
	   SUM(price*units) revenue
FROM ps
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 5;
--Top revenue store: Ciudad de Mexico 2 (Airport), Guadalajara 3 (Airport), Ciudad de Mexico 1 (Downtown), Toluca 1 (Downtown), Monterrey 2 (Downtown)

---Top 5 stores which gains the highest revenue for each location type
--Step 1: Indentify store location types
SELECT DISTINCT store_location
FROM mexicotoysales.stores;

--Step 2: Find top 5 stores with the highest revenue for each location type
SELECT st.store_location location_type,
       st.store_name,
	   SUM(pro.product_price*sa.units) revenue
FROM mexicotoysales.sales sa
LEFT JOIN mexicotoysales.products pro
ON sa.product_id=pro.product_id
LEFT JOIN mexicotoysales.stores st
ON sa.store_id=st.store_id
WHERE st.store_location='Airport'
/*WHERE st.store_location='Commercial'
WHERE st.store_location='Downtown'
WHERE st.store_location='Residential'*/
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 5;
--Stores in airports receieve more revenue than other locations
--In general, stores in Ciudad de Mexico tend to gain more than other cities, probably beacuase it is the capital of Mexico

---Top 5 products which gains the highest revenue for each location type
--Step 1: Indentify store location types
SELECT DISTINCT store_location
FROM mexicotoysales.stores;

--Step 2: Find top 5 products for each location type
SELECT st.store_location location_type,
       pro.product_name,
       SUM(pro.product_price*sa.units) revenue
FROM mexicotoysales.sales sa
LEFT JOIN mexicotoysales.products pro
ON sa.product_id=pro.product_id
LEFT JOIN mexicotoysales.stores st
ON sa.store_id=st.store_id
WHERE st.store_location='Airport'
/*WHERE st.store_location='Commercial'
WHERE st.store_location='Downtown'
WHERE st.store_location='Residential'*/
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 5;
--In general, location type specific top revenues for each product are quite similar with the situation in total, meaning that product preference is not highly associated with location

--Top 5 products with the highest revenue for each product category
--Step 1: Indentify product types
SELECT DISTINCT product_category
FROM mexicotoysales.products;

--Step 2: Find top 5 products for each product type
SELECT pro.product_category product_type,
       pro.product_name,
       SUM(pro.product_price*sa.units) revenue
FROM mexicotoysales.sales sa
LEFT JOIN mexicotoysales.products pro
ON sa.product_id=pro.product_id
WHERE pro.product_category='Art & Crafts'
/*WHERE pro.product_category='Electronics'
WHERE pro.product_category='Sports & Outdoors'
WHERE pro.product_category='Games'
WHERE pro.product_category='Toys'*/
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 5;
--The top 1 products in Art & Crafts, Electronics, Games and Toys performs far better than the other products in the same product category
--Products in Sports & Outdoors are much less poupular than the other products

--Top 5 stores with the highest revenue for each product type
--Step 1: Indentify product types
SELECT DISTINCT product_category
FROM mexicotoysales.products;

--Step 2: Find top 5 stores for each product type
SELECT pro.product_category product_type,
       st.store_name,
       SUM(pro.product_price*sa.units) revenue
FROM mexicotoysales.sales sa
LEFT JOIN mexicotoysales.products pro
ON sa.product_id=pro.product_id
LEFT JOIN mexicotoysales.stores st
ON sa.store_id=st.store_id
WHERE pro.product_category='Art & Crafts'
/*WHERE pro.product_category='Electronics'
WHERE pro.product_category='Sports & Outdoors'
WHERE pro.product_category='Games'
WHERE pro.product_category='Toys'*/
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 5;
--Arts & Crafts, Electronics & Games are revenue drivers for some of the stores, while the other two do not differ a lot



/*Identify Seasonal Trends & Patterns*/
---Total trends in revenue & profits
SELECT DATE_PART('year',sa.sale_date) yr,
       DATE_PART('quarter',sa.sale_date) qr,
	   SUM(pro.product_price*sa.units) revenue,
	   SUM((pro.product_price-pro.product_cost)*sa.units) profit
FROM mexicotoysales.sales sa
LEFT JOIN mexicotoysales.products pro
ON sa.product_id=pro.product_id
GROUP BY 1,2
ORDER BY 1,2; 
--Total revenue & profit all rise in second quarter and drop in third quarter
--In 2017, both revenue & profit rise again in Q4. Possible rise in these two aspects might occur again in 2018 Q4.  

---Find revenue trends for each product category
--Step 1: Indentify product category types
SELECT DISTINCT product_category
FROM mexicotoysales.products;

--Step 2: Find trends in revenue by product category
SELECT DATE_PART('year',sa.sale_date) yr,
       DATE_PART('quarter',sa.sale_date) qr,
	   SUM(CASE WHEN pro.product_category='Art & Crafts' THEN pro.product_price*sa.units ELSE NULL END) ac_rev,
	   SUM(CASE WHEN pro.product_category='Electronics' THEN pro.product_price*sa.units ELSE NULL END) e_rev,
	   SUM(CASE WHEN pro.product_category='Sports & Outdoors' THEN pro.product_price*sa.units ELSE NULL END) sp_rev,
	   SUM(CASE WHEN pro.product_category='Games' THEN pro.product_price*sa.units ELSE NULL END) g_rev,
	   SUM(CASE WHEN pro.product_category='Toys' THEN pro.product_price*sa.units ELSE NULL END) t_rev
FROM mexicotoysales.sales sa
LEFT JOIN mexicotoysales.products pro
ON sa.product_id=pro.product_id
GROUP BY 1,2
ORDER BY 1,2;
--One thing noticeable is that the revenue of Arts & Crafts increased dramatically since the forth quarter in 2017
--It seems that Maven might found a way to boost sales of this type of products during the forth quarter

---Find revenue trends by store location types
--Step 1: Indentify store location types
SELECT DISTINCT store_location
FROM mexicotoysales.stores;

--Step 2: Find trends in revenue by store location types
SELECT DATE_PART('year',sa.sale_date) yr,
       DATE_PART('quarter',sa.sale_date) qr,
	   SUM(CASE WHEN st.store_location='Airport' THEN pro.product_price*sa.units ELSE NULL END) a_rev,
	   SUM(CASE WHEN st.store_location='Commercial' THEN pro.product_price*sa.units ELSE NULL END) c_rev,
	   SUM(CASE WHEN st.store_location='Downtown' THEN pro.product_price*sa.units ELSE NULL END) d_rev,
	   SUM(CASE WHEN st.store_location='Residential' THEN pro.product_price*sa.units ELSE NULL END) r_rev
FROM mexicotoysales.sales sa
LEFT JOIN mexicotoysales.products pro
ON sa.product_id=pro.product_id
LEFT JOIN mexicotoysales.stores st
ON sa.store_id=st.store_id
GROUP BY 1,2
ORDER BY 1,2;
--The trends are the same compared to total trends: revenue,profit and volume all rise in second quarter and drop in third quarter



/*Inventory Costs Analysis*/
---Inventory costs and stocks on hand in general
SELECT SUM(i.stock_on_hand*pro.product_cost) inventory_cost,
       SUM(i.stock_on_hand) stocks_on_hand
FROM mexicotoysales.inventory i
LEFT JOIN mexicotoysales.products pro
ON i.product_id=pro.product_id;
--Inventory cost: $300K, Stocks on hand: Almost 30K

---Inventory cost by product types
WITH inventory_costs AS(
	 SELECT pro.product_id,
            pro.product_name,
            pro.product_category,
	        SUM(i.stock_on_hand*pro.product_cost) p_costs
     FROM mexicotoysales.inventory i
     LEFT JOIN mexicotoysales.products pro
     ON pro.product_id=i.product_id
     GROUP BY 1,2,3)
	 
SELECT SUM(p_costs) total_inventory_costs,
       SUM(CASE WHEN product_category='Art & Crafts' THEN p_costs ELSE NULL END) ac_inventory_costs,
	   SUM(CASE WHEN product_category='Electronics' THEN p_costs ELSE NULL END) e_inventory_costs,
	   SUM(CASE WHEN product_category='Sports & Outdoors' THEN p_costs ELSE NULL END) so_inventory_costs,
	   SUM(CASE WHEN product_category='Games' THEN p_costs ELSE NULL END) g_inventory_costs,
	   SUM(CASE WHEN product_category='Toys' THEN p_costs ELSE NULL END) t_inventory_costs
FROM inventory_costs;
--Toys has the largest inventory costs among the five product categories

---Inventory cost by products
SELECT pro.product_name product,
       SUM(i.stock_on_hand*pro.product_cost) product_costs
FROM mexicotoysales.inventory i
LEFT JOIN mexicotoysales.products pro
ON pro.product_id=i.product_id
GROUP BY 1
ORDER BY 2 DESC;
--Lego Bricks has the most money tied up in inventory

---Inventory cost by city
SELECT st.store_city city,
       SUM(i.stock_on_hand*pro.product_cost) inventory_costs
FROM mexicotoysales.stores st
LEFT JOIN mexicotoysales.inventory i
ON st.store_id=i.store_id
LEFT JOIN mexicotoysales.products pro
ON pro.product_id=i.product_id
GROUP BY 1
ORDER BY 2 DESC;
--Top 5 cities with high inventory costs: Ciudad de Mexico, Guadalajara, Hermosillo, Monterrey & Guanajuato

---Inventory cost by stores
SELECT st.store_name,
       SUM(i.stock_on_hand*pro.product_cost) inventory_costs
FROM mexicotoysales.stores st
LEFT JOIN mexicotoysales.inventory i
ON st.store_id=i.store_id
LEFT JOIN mexicotoysales.products pro
ON pro.product_id=i.product_id
GROUP BY 1
ORDER BY 2 DESC;
--Ciudad de Mexico 2 has the most inventory costs among all the stores



/*Merging Tables For Visualization*/
---For Sales Analysis
SELECT sa.sale_id,
       sa.sale_date,
	   sa.store_id,
	   st.store_name,
	   st.store_city,
	   st.store_location,
	   st.store_open_date,
	   sa.product_id,
	   pro.product_name,
	   pro.product_category,
	   pro.product_price,
	   pro.product_cost,
	   sa.units
FROM mexicotoysales.sales sa
LEFT JOIN mexicotoysales.products pro
ON sa.product_id=pro.product_id
LEFT JOIN mexicotoysales.stores st
ON sa.store_id=st.store_id;

---For Inventory Cost Analysis
SELECT i.store_id,
       st.store_name,
	   st.store_city,
	   st.store_location,
       i.product_id,
	   pro.product_name,
	   pro.product_category,
	   pro.product_cost,
	   i.stock_on_hand
FROM mexicotoysales.stores st
LEFT JOIN mexicotoysales.inventory i
ON st.store_id=i.store_id
LEFT JOIN mexicotoysales.products pro
ON pro.product_id=i.product_id;