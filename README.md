# Marketing_Portofolio_Project
This SQL code serves as both a learning resource and a personal portfolio to demonstrate my growing skills in data analysis and business intelligence.
# 📊 Marketing Performance Analytics – SQL + Power BI

The goal of this project is to investigate the performance of marketing campaign at ShopEasy, an online retail business, that facing reduced customer engagement and conversion rates despite launching several new online marketing campaigns. They are reaching out to you to help conduct a detailed analysis and identify areas for improvement in their marketing strategies


---

## 🔍 Business Questions

- Are we converting views into purchases efficiently?
- Which content types (Video, Social Media, Blog) drive the highest engagement?
- What products have the highest/lowest conversion rates?
- Is marketing effort translating into better customer sentiment?

---

## 🧰 Tools Used

- **SQL (MySQL):** Data cleaning, deduplication, transformation, exploration  
- **Power BI:** Dashboard visualization (conversion, rating, engagement)  
- **Excel (for CSV management)**

---

## 📁 Database Schema

Tables used:
- `customers`, `products`, `customer_reviews`, `customer_journey`, `engagement_data`

📌 *See `marketing.sql` for all cleaning & exploration queries.*

---

## 🧹 Data Preparation Highlights

- Removed duplicate rows using `ROW_NUMBER() OVER (...)`
- Standardized `ContentType` values (`'video' → 'Video'`, `'socialmedia' → 'Social Media'`)
- Split combined column `ViewsClicksCombined` into separate `views` and `clicks`
- Merged customer data with `geography` into a single `customers2` table

---

## 📈 Key Insights

### 1. 📉 Engagement naik, tapi conversion turun
Despite high visibility (9M+ views), **average conversion rate is only 9.57%**, with a **noticeable drop in Q3**.

### 2. 📱 Content performance
- **Social Media** and **Video** contribute 80%+ of engagement
- Blog posts generate steady interest but lower click rates

### 3. 🛍 Product with highest conversion
- `Hockey Stick` and `Ski Boots` reach **>14% conversion**
- `Swim Goggles` and `Yoga Mat` perform below average

### 4. ⭐ Customer sentiment
- Average rating across all products: **3.69**
- Highest-rated: **Climbing Rope (3.91)**  
- Lowest-rated: **Golf Clubs (3.48)**

### 5. 🧪 Specific Query Insight
> Customers who gave low ratings (<3) still made **multiple purchases**, indicating room for **product improvement** despite existing loyalty.

---

## 📊 Dashboard Preview

![dashboard](![Marketing projek_page-0001](https://github.com/user-attachments/assets/06528898-3e35-4147-ba3f-b3d83ac393a6)
![Marketing projek_page-0002](https://github.com/user-attachments/assets/57dc3287-5b11-429a-a6bc-f5424a4d5aa4)
![Marketing projek_page-0003](https://github.com/user-attachments/assets/29bb73b4-a3cc-494f-b458-e146ba7c42f8)
![Marketing projek_page-0004](https://github.com/user-attachments/assets/bca667b6-0d71-4252-ac95-8f92944708ac)
)  

