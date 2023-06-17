# Maven-Toys-Project

### Backgrounds & Goals for the Maven Toys Project

Maven Toys is a company which owns a chain of retail stores across Mexico, and has been selling toys, games, electronics and other types of products for about two years. The company approached you on Septemeber 30, 2018 and asked you to do some analysis for their sales performance in the past and inventory on this particular day, so that they could decide whether to adjust some of their strategies or not. 

The company had offered you a folder which contains information about sales records, products, stores and inventories. And the following are the main questions they would like you to answer:  

* Which product categories drive the biggest profits? Is it the same across store locations?

* Are there any seasonal trends or patterns in the sales data?

* How many stocks are tied up in the inventory? And how much are the inventory costs?

Also, they told you to feel free to dive deeper for the three questions above, they would be quite interested to see some additional insights.


### Steps I went through

#### 1. Data cleasing in Excel
* Activated filters for each column to see whether there are null values and outliers 
* Created table using Ctrl + T, and opened Power Query to see whether the data format is correct. Also made a second check for the null values and outliers
* Closed and load the data into Excel and save the file

#### 2. Conducted analysis according to the requests in PostgreSQL
   _See the .sql file in the repository for detail_

#### 3. Visualized my findings in Power BI
* Loaded the tables into Power BI
* Defined primary keys and foreign keys for each table, and connected them through the keys
* Ensured the filters are one-way filters
* Hided all the foreign keys in the table to prevent invalid filter context
* Created measures with DAX functions to calculate price, cost, profit, profit margin and units sold
* Designed interactive dashboards using graphs, tables, buttons and bookmark

_When creating maps, I noticed there were geographic ambiguities which made the bubbles to appear in the wrong location (e.g. Monterrey is the second largest city in Mexico, however, there's another Monterrey in California, US). So I created another table using Excel to store the longitude and latitude of each city to avoid abiguities, and imported this table to Power BI as well_

### Insights & Suggestions

* Throughout this period, Maven toys has gained $14.44M in revenue and $4.01M in profit, with a profit margin of 27.79%. 1.09M products were sold during this time period.

* Toys has the highest revenue & profit among all the four categories. And this does not differ a lot for each loacation.

* It can be clearly seen that the total revenue drops in the third quarter. In 2017, the revenue rise again in Q4, so it is highly likely that there will be a rise in the revenue in Q4, 2018.

* Another thing noticeable is that the revenue of Arts & Crafts increased dramatically since October 2017. It seems that Maven Toys might found a way to boost sales of this type of product.

* On Septemeber 30, 2018, there are almost 30K stocks in the inventory, and the inventory cost is $300K.

* Compared to the sales data and sales trends in the past, it is very likely that the customers will purchase more in the next three months. Therefore, Maven needs to increase their inventories to meet the protential increasing demand.

* Lego Bricks has the highest inventory cost. And although there are 550 Toy Robots and 622 PlayDoh Playsets in stock, the two products obtain the 6th and 7th highest inventory costs among all products. Based on the selling trend in last year, it is recommended that Maven Toys should reduce the inventory of PlayDoh Playset, since the sales of which are likely to drop in the next three months.

*Note: Maven Toys is a fictitious company.

_(Data Source: Maven Analytics)_
