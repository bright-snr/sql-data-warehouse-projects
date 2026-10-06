/*
===============================================================================
Quality checks
===============================================================================
Script Purpose:
This script performs various quality checks for data consistency, accuracy,
and standardization across the 'silver' schemas. It includes checks for:
- Null or duplication primary keys.
- Unwanted spaces in string fields.
- Data standardization and consistency.
- Invalid date ranges and orders.
- Data consistency between related fields.

Usage Notes:
- Run these checks after data loading silver Layer.
- Investigate and resolve any discrepancies found during the checks.
==================================================================================
*/

-- ===============================================================================
-- Check for Nulls or Duplicates in Primary key
-- Expectation: No result
-- ===============================================================================

SELECT 
cst_id,
count(*)
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING count(*) > 1 OR cst_id IS NULL

-- ===============================================================================
-- Check for unwanted spaces
-- Expectation: no Result
-- ===============================================================================
SELECT cst_firstname
FROM bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)


SELECT cst_lastname
FROM silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname)

SELECT cst_gndr
FROM silver.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr)

-- =============================================================================
-- Data standardization and consistency
-- =============================================================================

SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info

SELECT * FROM silver.crm_cust_info




-- =============================================================================
-- Check for nulls or duplicates in primary key
-- Expectation: no result
-- =============================================================================

SELECT
prd_id,
count(*)
FROM silver.crm_prd_info
group by prd_id
having count(*) > 1 or prd_id is null

-- ============================================================================
-- Check for unwanted space
-- Expectation : No results
-- ============================================================================

SELECT
prd_nm
FROM silver.crm_prd_info
where prd_nm != TRIM(prd_nm)

-- ============================================================================
-- Check fro Nulls or Negative Numbers
-- Expectation: No results
-- ============================================================================


SELECT
prd_cost
FROM silver.crm_prd_info
where prd_cost < 0 or prd_cost is null

-- ===========================================================================
-- Data standization and consistency
-- ===========================================================================

SELECT DISTINCT prd_line
FROM silver.crm_prd_info

-- ==========================================================================
-- Check for invalid date orders
-- ==========================================================================


SELECT
*
FROM silver.crm_prd_info
where prd_end_dt < prd_start_dt

SELECT
*
FROM silver.crm_prd_info



-- ===========================================================================
-- check for invalid dates
-- ===========================================================================

SELECT
NULLIF(sls_due_dt, 0) sls_due_dt
FROM silver.crm_sales_details
WHERE sls_due_dt <= 0
or LEN(sls_due_dt) != 8
or sls_due_dt > 20500001 
or sls_due_dt < 19000101

-- =============================================================================
-- check for invalid date orders
-- =============================================================================

SELECT 
* 
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt or sls_order_dt > sls_due_dt

-- ============================================================================
-- check data consistency: Between sales, Quantity, and price
-- >> Sales = Quantity * Price
-- >> Values must not be Null, zero, or negative
-- ============================================================================

SELECT
sls_sales AS old_sls_sales,
sls_quantity,
sls_price AS old_sls_price,
CASE WHEN sls_sales is null or sls_sales <= 0 or sls_sales != sls_quantity * ABS(sls_price)
     THEN sls_quantity * ABS(sls_price)
     ELSE sls_sales
END AS sls_sales,

CASE WHEN sls_price is null or sls_price <= 0
     THEN sls_sales/ NULLIF(sls_quantity, 0)
     ELSE sls_price
END AS sls_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
or sls_sales is null or sls_quantity is null or sls_price is null
or sls_sales <=0 or sls_quantity <=0 or sls_price <=0
order by sls_sales, sls_quantity, sls_price


SELECT
* FROM silver.crm_sales_details



-- ====================================================================
-- Standardization and cosistency
-- ====================================================================

SELECT DISTINCT 
cntry as old_cntry,
CASE WHEN TRIM(cntry) = 'DE'THEN 'Germany'
     WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
     WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
     ELSE TRIM(cntry)
END AS cntry
FROM bronze.erp_loc_a101
order by cntry

SELECT DISTINCT
cntry
FROM silver.erp_loc_a101
order by cntry

SELECT * FROM silver.erp_loc_a101



-- =========================================================
-- Identify out-of-Range Dates
-- =========================================================

SELECT DISTINCT
bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE()


-- ===========================================================
-- Data standardization and consistency
-- ===========================================================

SELECT DISTINCT gen
FROM silver.erp_cust_az12

select
CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
     WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
     ELSE 'n/a'
END AS gen
from silver.erp_cust_az12

SELECT * FROM silver.erp_cust_az12




-- ===========================================================
-- Check for unwanted spaces
-- ===========================================================
SELECT * FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat) or subcat != TRIM(subcat)
or maintenance != TRIM(maintenance)

-- ===========================================================
-- Data standardization and consistency
-- ===========================================================

SELECT DISTINCT
cat
FROM bronze.erp_px_cat_g1v2

SELECT DISTINCT
subcat
FROM bronze.erp_px_cat_g1v2

SELECT DISTINCT
maintenance
FROM bronze.erp_px_cat_g1v2

SELECT * FROM silver.erp_px_cat_g1v2
