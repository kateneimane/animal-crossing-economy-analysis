/* 
ANIMAL CROSSING: NEW HORIZONS ECONOMY ANALYSIS
Tools used: SQLite, TablePlus
Objective: Identify the most profitable activities on the island (fishing, bug catching, and crafting).
*/
-- SECTION 1: FISHING STRATEGY
-- Goal: Find the best fishing locations based on average sell price and species variety.
SELECT
	"Where/How" AS location,
	ROUND(AVG("Sell"), 0) AS avg_price,
	COUNT(*) AS species_count
FROM
	fish
GROUP BY
	"Where/How"
HAVING
	species_count > 5
ORDER BY
	avg_price DESC;

-- SECTION 2: BIODIVERSITY PROFITABILITY COMPARISON
-- Goal: Compare average and maximum prices between Fish and Insects to determine which is more lucrative.
WITH
	fauna_combined AS (
		SELECT
			"Name",
			"Sell",
			'Fish' AS type
		FROM
			fish
		UNION ALL
		SELECT
			"Name",
			"Sell",
			'Insect' AS type
		FROM
			insects
	)
SELECT
	type,
	ROUND(AVG("Sell"), 0) AS avg_price,
	MAX("Sell") AS max_price,
	COUNT(*) AS total_species,
	COUNT(
		CASE
			WHEN "Sell" < 1000 THEN 1
		END
	) AS cheap_count,
	COUNT(
		CASE
			WHEN "Sell" BETWEEN 1000 AND 5000  THEN 1
		END
	) AS fair_count,
	COUNT(
		CASE
			WHEN "Sell" > 5000 THEN 1
		END
	) AS expensive_count
FROM
	fauna_combined
GROUP BY
	type;

-- SECTION 3: CRAFTING MARGIN ANALYSIS (V2 - FULL SUPPLY CHAIN COST)
-- Goal: Calculate the true profit margin of high-value craftable items by subtracting 
-- the market value of ALL up to 6 potential ingredients used in the recipe.
WITH
	item_prices AS (
		SELECT
			"Name",
			"Sell"
		FROM
			housewares
		UNION
		SELECT
			"Name",
			"Sell"
		FROM
			miscellaneous
		UNION
		SELECT
			"Name",
			"Sell"
		FROM
			"wall-mounted"
		UNION
		SELECT
			"Name",
			"Sell"
		FROM
			tools
		UNION
		SELECT
			"Name",
			"Sell"
		FROM
			accessories
		UNION
		SELECT
			"Name",
			"Sell"
		FROM
			headwear
		UNION
		SELECT
			"Name",
			"Sell"
		FROM
			tops
		UNION
		SELECT
			"Name",
			"Sell"
		FROM
			bottoms
		UNION
		SELECT
			"Name",
			"Sell"
		FROM
			"dress-up"
		UNION
		SELECT
			"Name",
			"Sell"
		FROM
			socks
		UNION
		SELECT
			"Name",
			"Sell"
		FROM
			shoes
		UNION
		SELECT
			"Name",
			"Sell"
		FROM
			bags
		UNION
		SELECT
			"Name",
			"Sell"
		FROM
			fish
		UNION
		SELECT
			"Name",
			"Sell"
		FROM
			insects
		UNION
		SELECT
			"Name",
			"Sell"
		FROM
			other
	)
SELECT
	recipes."Name" AS item_name,
	recipes."Category",
	final_product."Sell" AS sell_price,
	recipes."Material 1" AS primary_material,
	recipes."#1" AS material_qty,
	mat1."Sell" AS material_unit_price,
	-- Full cost calculation
	(
		(COALESCE(recipes."#1", 0) * COALESCE(mat1."Sell", 0)) + (COALESCE(recipes."#2", 0) * COALESCE(mat2."Sell", 0)) + (COALESCE(recipes."#3", 0) * COALESCE(mat3."Sell", 0)) + (COALESCE(recipes."#4", 0) * COALESCE(mat4."Sell", 0)) + (COALESCE(recipes."#5", 0) * COALESCE(mat5."Sell", 0)) + (COALESCE(recipes."#6", 0) * COALESCE(mat6."Sell", 0))
	) AS total_materials_cost,
	-- True profit margin
	(
		final_product."Sell" - (
			(COALESCE(recipes."#1", 0) * COALESCE(mat1."Sell", 0)) + (COALESCE(recipes."#2", 0) * COALESCE(mat2."Sell", 0)) + (COALESCE(recipes."#3", 0) * COALESCE(mat3."Sell", 0)) + (COALESCE(recipes."#4", 0) * COALESCE(mat4."Sell", 0)) + (COALESCE(recipes."#5", 0) * COALESCE(mat5."Sell", 0)) + (COALESCE(recipes."#6", 0) * COALESCE(mat6."Sell", 0))
		)
	) AS estimated_profit
FROM
	recipes
	JOIN item_prices AS final_product ON recipes."Name" = final_product."Name"
	LEFT JOIN item_prices AS mat1 ON recipes."Material 1" = mat1."Name"
	LEFT JOIN item_prices AS mat2 ON recipes."Material 2" = mat2."Name"
	LEFT JOIN item_prices AS mat3 ON recipes."Material 3" = mat3."Name"
	LEFT JOIN item_prices AS mat4 ON recipes."Material 4" = mat4."Name"
	LEFT JOIN item_prices AS mat5 ON recipes."Material 5" = mat5."Name"
	LEFT JOIN item_prices AS mat6 ON recipes."Material 6" = mat6."Name"
WHERE
	final_product."Sell" > 5000
ORDER BY
	estimated_profit DESC
LIMIT
	20;

-- SECTION 4: SEASONAL FAUNA AVAILABILITY & POTENTIAL MARKET VALUE
-- Goal: Estimate the total "economic capacity" of the island per month by summing up 
-- the sell prices of all available fish and insect species (Northern Hemisphere).
-- Note: This is a "potential value" analysis and does not account for spawn rates or catch difficulty.
WITH
	fauna_monthly_values AS (
		SELECT
			"Name",
			'Insect' AS type,
			CASE
				WHEN "NH Jan" != 'NA' THEN 1
				ELSE 0
			END * "Sell" AS jan_value,
			CASE
				WHEN "NH Feb" != 'NA' THEN 1
				ELSE 0
			END * "Sell" AS feb_value,
			CASE
				WHEN "NH Mar" != 'NA' THEN 1
				ELSE 0
			END * "Sell" AS mar_value,
			CASE
				WHEN "NH Apr" != 'NA' THEN 1
				ELSE 0
			END * "Sell" AS apr_value,
			CASE
				WHEN "NH May" != 'NA' THEN 1
				ELSE 0
			END * "Sell" AS may_value,
			CASE
				WHEN "NH Jun" != 'NA' THEN 1
				ELSE 0
			END * "Sell" AS jun_value,
			CASE
				WHEN "NH Jul" != 'NA' THEN 1
				ELSE 0
			END * "Sell" AS jul_value,
			CASE
				WHEN "NH Aug" != 'NA' THEN 1
				ELSE 0
			END * "Sell" AS aug_value,
			CASE
				WHEN "NH Sep" != 'NA' THEN 1
				ELSE 0
			END * "Sell" AS sep_value,
			CASE
				WHEN "NH Oct" != 'NA' THEN 1
				ELSE 0
			END * "Sell" AS oct_value,
			CASE
				WHEN "NH Nov" != 'NA' THEN 1
				ELSE 0
			END * "Sell" AS nov_value,
			CASE
				WHEN "NH Dec" != 'NA' THEN 1
				ELSE 0
			END * "Sell" AS dec_value
		FROM
			insects
		UNION ALL
		SELECT
			"Name",
			'Fish' AS type,
			CASE
				WHEN "NH Jan" != 'NA' THEN 1
				ELSE 0
			END * "Sell" AS jan_value,
			CASE
				WHEN "NH Feb" != 'NA' THEN 1
				ELSE 0
			END * "Sell" AS feb_value,
			CASE
				WHEN "NH Mar" != 'NA' THEN 1
				ELSE 0
			END * "Sell" AS mar_value,
			CASE
				WHEN "NH Apr" != 'NA' THEN 1
				ELSE 0
			END * "Sell" AS apr_value,
			CASE
				WHEN "NH May" != 'NA' THEN 1
				ELSE 0
			END * "Sell" AS may_value,
			CASE
				WHEN "NH Jun" != 'NA' THEN 1
				ELSE 0
			END * "Sell" AS jun_value,
			CASE
				WHEN "NH Jul" != 'NA' THEN 1
				ELSE 0
			END * "Sell" AS jul_value,
			CASE
				WHEN "NH Aug" != 'NA' THEN 1
				ELSE 0
			END * "Sell" AS aug_value,
			CASE
				WHEN "NH Sep" != 'NA' THEN 1
				ELSE 0
			END * "Sell" AS sep_value,
			CASE
				WHEN "NH Oct" != 'NA' THEN 1
				ELSE 0
			END * "Sell" AS oct_value,
			CASE
				WHEN "NH Nov" != 'NA' THEN 1
				ELSE 0
			END * "Sell" AS nov_value,
			CASE
				WHEN "NH Dec" != 'NA' THEN 1
				ELSE 0
			END * "Sell" AS dec_value
		FROM
			fish
	)
SELECT
	SUM(jan_value) AS Jan_Total,
	SUM(feb_value) AS Feb_Total,
	SUM(mar_value) AS Mar_Total,
	SUM(apr_value) AS Apr_Total,
	SUM(may_value) AS May_Total,
	SUM(jun_value) AS Jun_Total,
	SUM(jul_value) AS Jul_Total,
	SUM(aug_value) AS Aug_Total,
	SUM(sep_value) AS Sep_Total,
	SUM(oct_value) AS Oct_Total,
	SUM(nov_value) AS Nov_Total,
	SUM(dec_value) AS Dec_Total
FROM
	fauna_monthly_values;