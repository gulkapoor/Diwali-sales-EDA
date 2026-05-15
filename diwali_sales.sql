/*
    DIWALI SALES DATA CLEANING PROJECT
*/

CREATE DATABASE IF NOT EXISTS Sales;

USE Sales;

SHOW TABLES;


-- View Dataset
SELECT *
FROM diwali_sales;


-- Drop Unnecessary Columns
ALTER TABLE diwali_sales
DROP COLUMN Status;

ALTER TABLE diwali_sales
DROP COLUMN unnamed1;

-- Create Shaadi Column
ALTER TABLE diwali_sales
ADD Shaadi VARCHAR(5);

UPDATE diwali_sales
SET Shaadi = CASE
                WHEN Marital_Status = 0 THEN 'No'
                WHEN Marital_Status = 1 THEN 'Yes'
             END;

ALTER TABLE diwali_sales
DROP COLUMN Marital_Status;


-- Standardize Gender Values
UPDATE diwali_sales
SET Gender = CASE
                WHEN Gender = 'F' THEN 'Female'
                WHEN Gender = 'M' THEN 'Male'
             END;


-- Remove NULL Amount Rows
DELETE FROM diwali_sales
WHERE Amount IS NULL;


-- Check Duplicate Records
WITH duplicate_value AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY 
                    User_ID,
                    Cust_name,
                    Product_ID,
                    Gender,
                    Age,
                    Product_Category,
                    Occupation,
                    Orders,
                    Amount,
                    Shaadi
               ORDER BY User_ID
           ) AS Row_num
    FROM diwali_sales
)

SELECT *
FROM duplicate_value
WHERE Row_num > 1;


-- Remove Duplicate Records
DELETE FROM diwali_sales
WHERE User_ID IN (

    SELECT User_ID
    FROM (

        SELECT User_ID,
               ROW_NUMBER() OVER (
                   PARTITION BY 
                        User_ID,
                        Cust_name,
                        Product_ID,
                        Gender,
                        Age,
                        Product_Category,
                        Occupation,
                        Orders,
                        Amount,
                        Shaadi
                   ORDER BY User_ID
               ) AS Row_num

        FROM diwali_sales

    ) AS temp_table

    WHERE Row_num > 1
);


-- Create Age Group Column
ALTER TABLE diwali_sales
ADD Age_Group VARCHAR(15);

UPDATE diwali_sales
SET Age_Group = CASE
                    WHEN Age < 18 THEN 'Below 18'
                    WHEN Age >= 18 AND Age <= 35 THEN '18-35'
                    WHEN Age > 35 AND Age <= 50 THEN '36-50'
                    WHEN Age > 50 AND Age <= 60 THEN '50-60'
                    WHEN Age > 60 THEN '60+'
                 END;


-- Final Cleaned Dataset
SELECT *
FROM diwali_sales;