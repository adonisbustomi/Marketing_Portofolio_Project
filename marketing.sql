drop database marketinganalytics;
create database marketing;
use marketing;
SET sql_mode = (SELECT REPLACE(@@sql_mode, 'ONLY_FULL_GROUP_BY', ''));
SHOW VARIABLES LIKE 'secure_file_priv';
set global local_infile = 1;
SET SQL_SAFE_UPDATES = 0;


create table customers
(
CustomerID int primary key,
Customername varchar(255),
email varchar (100),
gender varchar (100),
age varchar (100),
geographyID int
);

create table products
(
ProductID INT PRIMARY KEY,
ProductName VARCHAR(100),
Category VARCHAR(50),
Price DECIMAL(10,2)
);

create table customer_journey
(
    JourneyID INT PRIMARY KEY,
    CustomerID INT,
    ProductID INT,
    VisitDate DATE,
    Stage VARCHAR(50),         -- misal: Awareness, Consideration, Purchase
    Action VARCHAR(100),       -- misal: Clicked Ad, Viewed Product, etc.
    Duration INT,
    foreign key(CustomerID) references customers(CustomerID),
    foreign key(ProductID) references products(ProductID)
);

create table customer_reviews
(
ReviewID INT PRIMARY KEY,
CustomerID INT,
ProductID INT,
ReviewDate DATE,
Rating INT CHECK (Rating BETWEEN 1 AND 5),
ReviewText TEXT,
foreign key(CustomerID) references customers(CustomerID),
foreign key(ProductID) references products(ProductID)
);

create table engagement_data
(
EngagementID INT PRIMARY KEY,
ContentID VARCHAR(50),
ContentType VARCHAR(50),
Likes INT,
EngagementDate DATE,
CampaignID VARCHAR(50),
ProductID INT,
ViewsClicksCombined VARCHAR(20),
foreign key(ProductID) references products(ProductID)
);

create table geography
(
GeographyID INT PRIMARY KEY,
Country VARCHAR(50),
City VARCHAR(50)
);

load data local infile 'C:/Data housing/dbo.geography.csv'
into table geography
fields terminated by ',' enclosed by '"'
lines terminated by '\r\n'
ignore 1 lines;


select * from customer_reviews;
select * from engagement_data;
select * from customers;
select * from customer_journey;
select * from products;
select * from geography;

################################# STANDARDIZE DATA ####################################
## COSTUMER_REVIEWS membuang spasi pada kolom reviewtext
select
	reviewtext,
    replace(reviewtext,'  ', ' ')
from
	customer_reviews;

update customer_reviews
set reviewtext = replace(reviewtext,'  ', ' ');

## ENGAGEMENT_DATA replace 'Socialmedia / SOCIALMEDIA' menjadi 'Social Media'
-- 'video' menjadi 'Video'
-- 'newsletter' menjadi 'Newsletter'
select
	distinct contenttype
from
	engagement_data;

update engagement_data
set contenttype = 'Video'
where contenttype like 'video%';

update engagement_data
set contenttype = 'Newsletter'
where contenttype like 'newsletter%';

update engagement_data
set contenttype = 'Social Media'
where contenttype like 'socialmedia%';

-- buat table engagement_data2 yang mana data views dan clicks sudah dipisahkan menjadi kolom yang berbeda
select
	EngagementID,  
    ContentID,  
	CampaignID,  
    ProductID,
    ContentType,
    Likes,
    EngagementDate,
    substring_index(viewsclickscombined,'-',1) as views,
    -- atau bisa pakai ini:
    -- left(viewsclickscombined), char_length(viewsclickscombined) - 
	-- char_length(substring_index(viewsclickscombined,'-',-1))-1)
    substring_index(viewsclickscombined,'-',-1) as clicks
from
	engagement_data;
    
create table engagement_data2
(
EngagementID INT PRIMARY KEY,
ContentID VARCHAR(50),
CampaignID VARCHAR(50),
ProductID INT,
ContentType VARCHAR(50),
Likes INT,
EngagementDate DATE,
Views INT,
Clicks INT,
foreign key(ProductID) references products(ProductID)
);

insert into engagement_data2
select
	EngagementID,  
    ContentID,  
	CampaignID,  
    ProductID,
    ContentType,
    Likes,
    EngagementDate,
    substring_index(viewsclickscombined,'-',1) as Views,
    -- atau bisa pakai ini:
    -- left(viewsclickscombined), char_length(viewsclickscombined) - 
	-- char_length(substring_index(viewsclickscombined,'-',-1))-1)
    substring_index(viewsclickscombined,'-',-1) as Clicks
from
	engagement_data;
    
select * from engagement_data2;

## CUSTOMERS menggabungkan data customers dan geography
select
	*
from
	customers c
join
	geography g on c.geographyid = g.geographyid;
    
select
	c.CustomerID,
    c.CustomerName,
    c.Email,
    c.Gender,
    c.Age,
    G.Country,
    G.City
from
	customers c
join
	geography g on c.geographyid = g.geographyid;

create table Customers2
(
CustomerID int primary key,
Customername varchar(255),
Email varchar (100),
Gender varchar (100),
Age varchar (100),
Country varchar(100),
City varchar(100)
);

insert into Customers2
select
	c.CustomerID,
    c.CustomerName,
    c.Email,
    c.Gender,
    c.Age,
    G.Country,
    G.City
from
	customers c
join
	geography g on c.geographyid = g.geographyid;

select * from customers2;

############################## REMOVING DUPLICATES ROWS ###########################
## CUSTOMER_JOURNEY
-- cek duplikat
select
	*,
    row_number() over
    (partition by 
    CustomerID,
    ProductID,
    VisitDate,
    Stage,
    Action
    order by journeyid) as row_num
from
	customer_journey;
    
with duplicates as
(
select
	*,
    row_number() over
    (partition by 
    CustomerID,
    ProductID,
    VisitDate,
    Stage,
    Action
    order by journeyid) as row_num
from
	customer_journey
)
select
	*
from
	duplicates
where
	row_num > 1;

########################### DATA EXPLORATION #########################
select * from customer_reviews;
select * from engagement_data2;
select * from customers2;
select * from customer_journey;
select * from products;

-- KEY POINT 1 Peningkatan investasi marketing tapi customer engagement and conversion rates nya turun
-- KPI CUSTOMER ENGAGEMENT:CLICKS, VIEWS, LIKES BERDASARKAN TIPE KONTEN
############################### Engagement contenttype #####################################
-- melihat jumlah likes, views, dan clicks tiap contenttype
select
	contenttype,
    sum(likes) as likes,
    sum(views) as views,
    sum(clicks) as clicks
from
	engagement_data2
where
	contenttype not in ('Newsletter')
group by
	1;
    
-- melihat total likes views dan clicks gabungan dari seluruh contenttype
with engagement_per_content as
(
select
	contenttype,
    sum(likes) as likes,
    sum(views) as views,
    sum(clicks) as clicks
from
	engagement_data2
where
	contenttype not in ('Newsletter')
group by
	1
)
select
    sum(likes) as total_likes,
    sum(views) as total_views,
    sum(clicks) as total_clicks
from
	engagement_per_content;


-- melihat likes views clicks pertahun
select
	year(engagementdate) as calendar_year,
    sum(likes) as likes,
    sum(views) as views,
    sum(clicks) as clicks
from
	engagement_data2
group by
	calendar_year
order by 1;

-- campaignid dan contentid penyumbang views tertinggi
select 
	campaignid,
    contentid,
    sum(likes) as likes,
    sum(views) as views,
    sum(clicks) as clicks,
    rank() over(order by sum(views)desc) as ranking
from 
	engagement_data2
group by 1,2;

-- contenttype yang mendapatkan views tertinggi
select
	contenttype,
    sum(likes) as likes,
    sum(views) as views,
    sum(clicks) as clicks,
    row_number() over(order by sum(views) desc) as row_num
from
	engagement_data2
where
	contenttype not in ('Newsletter')
group by
	1;
-- engagement perbulan
select
	month(engagementdate) as calendar_month,
    sum(views),
    sum(clicks),
    sum(likes)
from
	engagement_data2
group by
	1
order by 1;
-- engagement per produk
select
	productid,
    sum(views),
    sum(clicks),
    sum(likes)
from
	engagement_data2
group by
	1
order by 1;

-- views per produk per bulan
select
	month(ed.engagementdate) as calendar_month,
	p.productname,
    sum(views)
from
	engagement_data2 ed
join
	products p on ed.productid = p.productid
where
	ed.contenttype not in ('Newsletter')
group by
	1,2
order by 1;

-- views per produk per campaignid
select
	month(ed.engagementdate) as calendar_month,
	campaignid,
    sum(views)
from
	engagement_data2 ed
join
	products p on ed.productid = p.productid
where
	ed.contenttype not in ('Newsletter')
group by
	1,2
order by 1;



    
################################ conversion #################################

select * from customer_journey
order by 2;
select count(distinct journeyid) from customer_journey;
select distinct action from customer_journey;
select * from engagement_data2;

-- berapa customer yang masuk ke setiap stage
select
	cj.stage,
    count(c.customerid) as customer
from
	customer_journey cj
join
	customers2 c on cj.customerid = c.customerid
group by
	1;
    
-- journey customer dari stage ke tahap berikutnya
select
	cj.stage,
    cj.action,
    count(c.customerid) as customer
from
	customer_journey cj
join
	customers2 c on cj.customerid = c.customerid
group by
	1,2
order by 1;

-- jumlah yang terpurchase berdasarkan productid
select
	cj.productid,
    sum(case when cj.action = 'Purchase' then 1 else 0 end) as purchase_count
from
	customer_journey cj
group by 1;

-- coversion rate total purchase / total view   
with journey as
(
select
	sum(case when cj.action = 'view' then 1 else 0 end) as views,
    sum(case when cj.action = 'click' then 1 else 0 end) as clicks,
    sum(case when cj.action = 'drop-off' then 1 else 0 end) as drop_off,
    sum(case when cj.action = 'Purchase' then 1 else 0 end) as purchase
from
	customer_journey cj
)
	select
        sum(purchase / views) * 100 as conversion
	from
		journey;
        

-- conversion rate per bulan
with journey as
(
select
	month(visitdate) as calendar_month,
	sum(case when cj.action = 'View' then 1 else 0 end) as views,
    sum(case when cj.action = 'Purchase' then 1 else 0 end) as purchase
from
	customer_journey cj
group by
	1
)
select
	calendar_month,
    views,
    purchase,
    round(sum(purchase / views * 100),2) as conversion_rate
from
	journey
group by
	1
order by
	1;

-- conversion rate per product
with journey as
(
select
	p.productname,
	sum(case when cj.action = 'View' then 1 else 0 end) as views,
    sum(case when cj.action = 'Purchase' then 1 else 0 end) as purchase
from
	products p
join
	customer_journey cj on p.productid = cj.productid
group by
	1
)
select
	p.productname,
    views,
    purchase,
    round(sum(purchase / views * 100),2) as conversion_rate
from
	products p
join
	journey j on p.productname = j.productname
group by
	1
order by
	1;

select * from customer_journey;
select * from engagement_data2;

    
-- produk penyumbang sales tertinggi (purchase count * price)
with purchase_count as
(
select
	p.productname,
    p.price,
    count(cj.action) as purchase
from
	products p
join
	customer_journey cj on p.productid = cj.productid
group by
	1
)
select
	pc.productname,
    sum(purchase * price) as sales,
    row_number() over(order by sum(purchase * price) desc) as ranking
from
	purchase_count pc
group by
	1;
# NOTES:  ketika mau menghitung 2 konteks yang
# berbeda dari table yang berbeda kita harus agregasiin dulu masing2 baru digabung pake CTE



########################### CUSTOMER REVIEWS ##################
-- cek berapa kali customer yang purchase
select
	c.customerid,
    c.customername,
    count(cj.action) as purchase_count
from
	customers2 c
join
	customer_journey cj on c.customerid = cj.customerid
where
	cj.action = 'purchase'
group by
	1,2
order by 3 desc;

-- CEK  RATING PRODUK beserta banyaknya produk yang dibeli oleh customer

with total_purchase as
(
select
	c.customerid,
    c.customername,
    count(cj.action) as purchase
from
	customers2 c
join
	customer_journey cj on c.customerid = cj.customerid
where
	cj.action = 'Purchase'
group by
	1,2
)
select
	tp.customerid,
    tp.customername,
    p.productid,
    p.productname,
    cr.rating,
    tp.purchase
from
	total_purchase tp
join
	customer_journey cj on tp.customerid = cj.customerid
left join
	customer_reviews cr on cj.productid = cr.productid and cr.customerid = cj.customerid
join
	products p on cr.productid = p.productid
where cj.action = 'Purchase'
ORDER BY tp.customername;


    
-- check berapa kali pelanggan melakukan pembelian berdasarkan produk yang mereka beli dan ratingnya
WITH purchase_total AS (
  SELECT
    c.customerid,
    c.customername,
    COUNT(cj.action) AS total_purchase
  FROM customers2 c
  JOIN customer_journey cj ON c.customerid = cj.customerid
  WHERE cj.action = 'Purchase' AND cj.stage = 'Checkout'
  GROUP BY c.customerid, c.customername
)
SELECT
  pt.customerid,
  pt.customername,
  p.productid,
  p.productname,
  cr.rating,
  pt.total_purchase
FROM purchase_total pt
JOIN customer_journey cj ON pt.customerid = cj.customerid
JOIN products p ON cj.productid = p.productid
left JOIN customer_reviews cr ON cj.customerid = cr.customerid AND cj.productid = cr.productid
WHERE cj.action = 'Purchase' AND cj.stage = 'Checkout'
ORDER BY pt.customername;
## NOTES; DARI HASIL QUERY DIATAS 
-- berarti dari produk yang mereka beli, ada salah satu produk yang mereka review lebih dari 1 kali
-- BISA DILIHAT DI RATINGNYA. PRODUKNYA SAMA TAPI RATING BEDA(ADA JUGA RATING YANG NULL)

-- check berapa kali orang melakukan review di product yang mereka beli
select
	c.customerid,
    c.customername,
    cr.productid,
    p.productname,
    count(cr.reviewid) as review_count
from
	customer_reviews cr
join
	customer_journey cj on cr.customerid = cj.customerid
    and cj.productid = cr.productid
join
	products p on cr.productid = p.productid
join
	customers2 c on cr.customerid = c.customerid
where
	cj.action = 'Purchase'
    and cj.stage = 'Checkout'
group by
	1,2,3,4
having
	review_count >1
order by 2;

-- check pembelian customer beserta ratingnya di filter berdasarkan review terakhir (reviewdate desc)
WITH latest_reviews AS (
  SELECT 
    customerid,
    productid,
    rating,
    reviewdate,
    ROW_NUMBER() OVER (
      PARTITION BY customerid, productid
      ORDER BY reviewdate DESC
    ) AS rn
  FROM customer_reviews
),
purchase_total AS (
  SELECT
    c.customerid,
    c.customername,
    COUNT(*) AS total_purchase
  FROM customers2 c
  JOIN customer_journey cj ON c.customerid = cj.customerid
  WHERE cj.action = 'Purchase' AND cj.stage = 'Checkout'
  GROUP BY c.customerid, c.customername
)
SELECT
  pt.customerid,
  pt.customername,
  p.productid,
  p.productname,
  lr.rating,
  pt.total_purchase
FROM purchase_total pt
JOIN customer_journey cj ON pt.customerid = cj.customerid
JOIN products p ON cj.productid = p.productid
LEFT JOIN latest_reviews lr 
  ON cj.customerid = lr.customerid AND cj.productid = lr.productid AND lr.rn = 1
WHERE cj.action = 'Purchase' AND cj.stage = 'Checkout'
ORDER BY pt.customername;

-- menklasifikasikan rating
select
	*
from
	customer_reviews;

select
	c.customerid,
	c.customername,
	p.productid,
    p.productname,
    cr.rating as rating,
    cr.reviewtext,
    case
		when rating < 3 then 'Negative'
        when rating = 3 then 'Mid'
        else 'Positive' end as sentiment
from
	customers2 c
join
	customer_reviews cr on c.customerid = cr.customerid
join
	products p on cr.productid = p.productid;
    
SELECT * FROM CUSTOMERS2;
SELECT * FROM CUSTOMER_JOURNEY;

    