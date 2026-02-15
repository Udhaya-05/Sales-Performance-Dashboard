-- 🔹 STEP 1: Create Database & Use It
CREATE DATABASE IF NOT EXISTS online_retail;
USE online_retail;

-- 🔹 STEP 2: Drop Existing Table (if re-running)
DROP TABLE IF EXISTS retail_sales;

-- 🔹 STEP 3: Create Clean Table Schema
CREATE TABLE retail_sales (
    InvoiceNo VARCHAR(20),
    StockCode VARCHAR(20),
    Description TEXT,
    Quantity INT,
    InvoiceDate DATETIME,
    UnitPrice DECIMAL(10,2),
    CustomerID INT NULL,
    Country VARCHAR(100)
);

-- 📝 Notes:
-- - InvoiceNo: Unique order ID (can start with "C" for returns)
-- - Quantity/UnitPrice: Cleaned to remove invalid values
-- - CustomerID: NULLs allowed
-- - InvoiceDate: Cleaned to match YYYY-MM-DD HH:MM:SS format in Excel

-- 🔹 STEP 4: Load Cleaned Data (Optional if using CSV)
-- Requires LOCAL INFILE support enabled
-- Uncomment and update path if using

LOAD DATA LOCAL INFILE 'C:\Users\Udhaya\OneDrive\Documents\DS project\Sales-Insights-Dashboard\retail_sales_combined.csv'
INTO TABLE retail_sales
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(InvoiceNo, StockCode, Description, Quantity, InvoiceDate, UnitPrice, CustomerID, Country);


-- 🔹 STEP 5: Clean and Validate Data

-- A. Remove zero or negative values (already cleaned in Excel, but double-check)
DELETE FROM retail_sales
WHERE Quantity <= 0 OR UnitPrice <= 0;

-- B. Check NULLs in CustomerID
SELECT COUNT(*) AS NullCustomerIDs
FROM retail_sales
WHERE CustomerID IS NULL;

-- C. Confirm remaining row count
SELECT COUNT(*) AS TotalCleanedRows FROM retail_sales;

-- 🔹 STEP 6: Create Invoice-Level Revenue View
-- Each invoice total = SUM(Quantity × UnitPrice)
CREATE OR REPLACE VIEW invoice_revenue_summary AS
SELECT
    InvoiceNo,
    CustomerID,
    Country,
    DATE(InvoiceDate) AS InvoiceDateOnly,
    SUM(Quantity * UnitPrice) AS TotalInvoiceRevenue,
    SUM(Quantity) AS TotalUnits,
    COUNT(DISTINCT StockCode) AS UniqueItems
FROM retail_sales
GROUP BY InvoiceNo, CustomerID, Country, DATE(InvoiceDate);

-- 🔹 STEP 7: Create Daily Revenue Summary (for trend charting)
CREATE OR REPLACE VIEW daily_revenue_summary AS
SELECT
    DATE(InvoiceDate) AS SaleDate,
    SUM(Quantity * UnitPrice) AS DailyRevenue,
    COUNT(DISTINCT InvoiceNo) AS DailyOrders
FROM retail_sales
GROUP BY DATE(InvoiceDate)
ORDER BY SaleDate;

-- 🔹 STEP 8: Identify High-Revenue Invoices (Optional — for B2B detection)
-- Let's flag invoices with revenue > 20,000
CREATE OR REPLACE VIEW high_value_invoices AS
SELECT *
FROM invoice_revenue_summary
WHERE TotalInvoiceRevenue > 20000;

-- 🔹 STEP 9: Export Recommendations
-- Power BI can connect directly to:
-- - retail_sales for raw data
-- - invoice_revenue_summary for invoice-level analysis
-- - daily_revenue_summary for trend analysis
-- - high_value_invoices for B2B segmentation

-- 🔹 STEP 10: Sample Data Check
SELECT * FROM invoice_revenue_summary ORDER BY TotalInvoiceRevenue DESC LIMIT 5;
SELECT * FROM high_value_invoices LIMIT 5;
