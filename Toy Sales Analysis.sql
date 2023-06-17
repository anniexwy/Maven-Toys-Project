----First, I created a schema called "mexicotoysales" to store the tables for analysis. Four tables are included in this schema: 
----inventory (incl. store id for each stores, product id for each products & stock on hand for each stores, divided by products),
----products (incl. product id for each stores, product name, product category, cost of each type of product & price of each type of product)
----sales (incl. sale id for each purchase record, dates for the purchases, store id for each stores, product id for each stores & units sold for each purchase)
----stores (incl. store id for each stores, store name for each stores, city where the stores loacated in, type of store location & the date the stores opened)

----Then, I conducted the analysis below


/*Revenue, Profit, Profit Margin & Units Sold in General*/
SELECT SUM(pro.product_price*sa.units) revenue,
	   SUM((pro.product_price-pro.product_cost)*sa.units) profit,
	   ROUND(SUM((pro.product_price-pro.product_cost)*sa.units)/SUM(pro.product_price*sa.units),4) profit_margin,
	   SUM(sa.units) units_sold
FROM mexicotoysales.sales sa        -- For PostgreSQL, you have to identify which schema the table belongs to when pulling data from the tables, in order to avoid ambiguity
LEFT JOIN mexicotoysales.products pro
ON sa.product_id=pro.product_id
--Revenue: $14.44M, Profit: $4.01M, Profit Margin: 27.79%, Units Sold: 1.09M



/*Sales Analysis from Different Aspects*/
---Find the city with the highest revenue, margin, profit margin, number of purchases and units sold
SELECT st.store_city,
       SUM(pro.product_price*sa.units) revenue,
	   SUM((pro.product_price-pro.product_cost)*sa.units) profit,
	   ROUND(SUM((pro.product_price-pro.product_cost)*sa.units)/SUM(pro.product_price*sa.units),4) profit_margin,
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
ORDER BY 5 DESC;*/
--Stores in Cuidad de Mexico obtain the highest revenue, profit & units sold
--Stores in Morelia has the highest profit margin than stores in other areas


---Find the type of stores loctaion with the highest revenue, margin, profit margin & units sold
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
	   SUM(units) units_sold
FROM product_sales
GROUP BY 1
ORDER BY 2 DESC;
--Stores in downtown area have the highest revenue, profit & units sold in total
--Stores in airports have the highest profit margin in total


---Find the product categories with the biggest revenue, margin, profit margin & units sold
SELECT pro.product_category,
       SUM(pro.product_price*sa.units) revenue,
	   SUM((pro.product_price-pro.product_cost)*sa.units) profit,
	   ROUND(SUM((pro.product_price-pro.product_cost)*sa.units)/SUM(pro.product_price*sa.units),4) profit_margin,
	   SUM(sa.units) units_sold
FROM mexicotoysales.sales sa
LEFT JOIN mexicotoysales.products pro
ON sa.product_id=pro.product_id
GROUP BY 1
ORDER BY 2 DESC;
/*ORDER BY 3 DESC;
ORDER BY 4 DESC;
ORDER BY 5 DESC;*/
--Toys have the highest revenue & profit among all the four categories
--Arts & Crafts have the second highest revenue, yet has the third highest profit, and has the highest units sold.
--Electronics have much more higher profit margin than the other four categories


---Calculate the revenues of each type of products of each location type to see whether there are differences
SELECT pro.product_category,
       SUM(CASE WHEN st.store_location='Airport' THEN pro.product_price*sa.units ELSE NULL END) a_rev,
	   SUM(CASE WHEN st.store_location='Downtown' THEN pro.product_price*sa.units ELSE NULL END) d_rev,
	   SUM(CASE WHEN st.store_location='Residential' THEN pro.product_price*sa.units ELSE NULL END) r_rev,
	   SUM(CASE WHEN st.store_location='Commercial' THEN pro.product_price*sa.units ELSE NULL END) c_rev
FROM mexicotoysales.sales sa
LEFT JOIN mexicotoysales.products pro
ON sa.product_id=pro.product_id
LEFT JOIN mexicotoysales.stores st
ON sa.store_id=st.store_id
GROUP BY 1
--Toys still have the highest revenue among all the four product categories


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
---Total trends in revenue
SELECT DATE_PART('year',sa.sale_date) yr,
       DATE_PART('month',sa.sale_date) mo,
	   SUM(pro.product_price*sa.units) revenue
FROM mexicotoysales.sales sa
LEFT JOIN mexicotoysales.products pro
ON sa.product_id=pro.product_id
GROUP BY 1,2
ORDER BY 1,2; 
--Total revenue drops in the third quarter
--In 2017, the revenue rise again in Q4. Possible rise in the revenue might occur again in 2018 Q4.  


---Find revenue trends for each product category
--Step 1: Indentify product category types
SELECT DISTINCT product_category
FROM mexicotoysales.products;

--Step 2: Find trends in revenue by product category
SELECT DATE_PART('year',sa.sale_date) yr,
       DATE_PART('month',sa.sale_date) mo,
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
--One thing noticeable is that the revenue of Arts & Crafts increased dramatically since October 2017.
--It seems that Maven Toys might found a way to boost sales of this type of product


---Find revenue trends by store location types
--Step 1: Indentify store location types
SELECT DISTINCT store_location
FROM mexicotoysales.stores;

--Step 2: Find trends in revenue by store location types
SELECT DATE_PART('year',sa.sale_date) yr,
       DATE_PART('month',sa.sale_date) mo,
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
--The trends are the same compared to total trends: revenue,profit and volume all drop in third quarter



/*Inventory Costs Analysis*/
---Inventory costs and stocks on hand in general
SELECT SUM(i.stock_on_hand*pro.product_cost) inventory_cost,
       SUM(i.stock_on_hand) stocks_on_hand
FROM mexicotoysales.inventory i
LEFT JOIN mexicotoysales.products pro
ON i.product_id=pro.product_id;
--Inventory cost: $300K, Stocks on hand: Almost 30K

---Since there are almost 30k stocks on hand, are they enough to cope with the demand in the future?
---Let's take a look at the historical data of unit sales in the past
SELECT DATE_PART('year', sale_date) yr,
       DATE_PART('month',sale_date) mo,
	   SUM(units) units_sold
FROM mexicotoysales.sales
GROUP BY 1,2
ORDER BY 1,2;
--In Septemeber 2018, Maven Toys has more than 52k units sold in total. 
--According to the historical data, it is very likely that the customers will purchase more in the next three months. 
--Therefore, Maven needs to increase their inventories to meet the protential increasing demand.


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
SELECT pro.product_id,
       pro.product_name product,
       SUM(i.stock_on_hand) stock_units,
       SUM(i.stock_on_hand*pro.product_cost) product_costs
FROM mexicotoysales.inventory i
LEFT JOIN mexicotoysales.products pro
ON pro.product_id=i.product_id
GROUP BY 1
ORDER BY 4 DESC;
--Lego Bricks has the highest inventory cost. 
--And although there are 550 Toy Robots and 622 PlayDoh Playsets in stock, the two products obtain the 6th and 7th highest inventory costs among all products.

---Dive Deeper: in order to cut down inventory costs, which product should we reduce the number of stocks on hand?
--Step 1: Find the product costs of each product
SELECT product_id,
       product_name,
       product_cost
FROM mexicotoysales.products
ORDER BY 3 DESC;
--The top 3 expensive products are: Lego Bricks ($34.99), PlayDoh Playset ($20.99) & Toy Robot ($20.99)

--Step 2: Find the trends of sold units for the three products 
SELECT DATE_PART('year', sa.sale_date) yr,
       DATE_PART('month',sa.sale_date) mo,
	   SUM(CASE WHEN pro.product_name='Lego Bricks' THEN sa.units ELSE NULL END) lb,
	   SUM(CASE WHEN pro.product_name='PlayDoh Playset' THEN sa.units ELSE NULL END) pp,
	   SUM(CASE WHEN pro.product_name='Toy Robot' THEN sa.units ELSE NULL END) tb
FROM mexicotoysales.sales sa
LEFT JOIN mexicotoysales.products pro
ON pro.product_id=sa.product_id
GROUP BY 1,2
ORDER BY 1,2;
--There are 2309 units of Lego Bricks, 288 units of PlayDoh Playset, and 486 units of Toy Robot sold in Septemeber, 2018. 
--Based on the selling trend in last year, it is recommended that Maven Toys should reduce the inventory of PlayDoh Playset, since the sales of which are likely to drop in the next three months.


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