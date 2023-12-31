
/* 1- Counting the number of sessions and orders per month coming from "gsearch"-------------------------------------------------------
"Gsearch seems to be the biggest driver of our business. Could you pull monthly trends for gsearch sessions and orders so that we can showcase the growth there?-------------
*/

SELECT
	YEAR(ws.created_at) AS year,
    MONTHNAME(ws.created_at) AS month,
    MIN(DATE(ws.created_at)) AS start_of_month,
    COUNT(ws.website_session_id) AS sessions,
    COUNT(o.order_id) AS orders,
    COUNT(o.order_id)/COUNT(ws.website_session_id) AS CVR
FROM
    website_sessions ws
        LEFT JOIN
    orders o ON o.website_session_id = ws.website_session_id
WHERE
   ws.utm_source = 'gsearch'
   AND ws.created_at < '2012-11-27'
GROUP BY month
ORDER BY month;

/* 2- Ditto but separated by campaign.
Next, it would be great to see a similar monthly trend for Gsearch, but this time splitting out nonbrand and brand campaigns separately. I am wondering if brand is picking up at all. If so, this is a good story to tell.
*/

SELECT 
    YEAR(ws.created_at) AS year,
    MONTHNAME(ws.created_at) AS month,
    MIN(DATE(ws.created_at)) AS start_of_month,
	COUNT(CASE WHEN ws.utm_campaign = "brand" THEN ws.website_session_id ELSE NULL END) AS branded_sessions,
    COUNT(CASE WHEN ws.utm_campaign = "brand" THEN o.order_id ELSE NULL END) AS branded_orders,
    COUNT(CASE WHEN ws.utm_campaign = "nonbrand" THEN ws.website_session_id ELSE NULL END) AS nonbranded_sessions,
    COUNT(CASE WHEN ws.utm_campaign = "nonbrand" THEN o.order_id ELSE NULL END) AS nonbranded_orders,
    COUNT(ws.website_session_id) AS total_sessions,
    COUNT(o.order_id) AS total_orders
FROM
    website_sessions ws
        LEFT JOIN
    orders o ON o.website_session_id = ws.website_session_id
WHERE
    ws.utm_source = 'gsearch'
        AND ws.created_at < '2012-11-27'
GROUP BY month
ORDER BY start_of_month;

/* 3-- Ditto but only the "nonbrand" campaign, separated by device type.
While we’re on Gsearch, could you dive into nonbrand, and pull monthly sessions and orders split by device type? I want to flex our analytical muscles a little and show the board we really know our traffic sources. 
*/

SELECT 
	YEAR(ws.created_at) AS year,
    MONTHNAME(ws.created_at) AS month,
    MIN(DATE(ws.created_at)) AS start_of_month,
	COUNT(CASE WHEN ws.device_type = "mobile" THEN ws.website_session_id ELSE NULL END) AS mobile_sessions,
    COUNT(CASE WHEN ws.device_type = "mobile" THEN o.order_id ELSE NULL END) AS mobile_orders,
    COUNT(CASE WHEN ws.device_type = "mobile" THEN o.order_id ELSE NULL END)/COUNT(CASE WHEN ws.device_type = "mobile" THEN ws.website_session_id ELSE NULL END) AS mobile_CVR,
    COUNT(CASE WHEN ws.device_type = "desktop" THEN ws.website_session_id ELSE NULL END) AS desktop_sessions,
    COUNT(CASE WHEN ws.device_type = "desktop" THEN o.order_id ELSE NULL END) AS desktop_orders,
    COUNT(CASE WHEN ws.device_type = "desktop" THEN o.order_id ELSE NULL END)/COUNT(CASE WHEN ws.device_type = "desktop" THEN ws.website_session_id ELSE NULL END) AS dekstop_CVR,
    COUNT(ws.website_session_id) AS total_sessions,
    COUNT(o.order_id) AS total_orders
FROM
    website_sessions ws
        LEFT JOIN
    orders o ON o.website_session_id = ws.website_session_id
WHERE
    ws.utm_source = 'gsearch'
    AND ws.utm_campaign = 'nonbrand'
    AND ws.created_at < '2012-11-27'
GROUP BY month
ORDER BY start_of_month;

/* 4- Ditto but "gsearch" against the rest of the channels.
 I’m worried that one of our more pessimistic board members may be concerned about the large % of traffic from Gsearch. Can you pull monthly trends for Gsearch, alongside monthly trends for each of our other channels?
*/
-- finding all the channels from which traffic can arrive
SELECT DISTINCT
	utm_source,
    utm_campaign,
    http_referer
FROM website_sessions;
-- the traffic coming from bsearch and gsearch UTM sources is paid, the traffic coming from the gsearch and bsearch websites without a UTM source is search traffic, and the traffic coming directly into the site.
SELECT 
	YEAR(ws.created_at) AS year,
    MONTHNAME(ws.created_at) AS month,
    MIN(DATE(ws.created_at)) AS start_of_month,
    -- COUNT(ws.website_session_id) AS total_sessions,
	COUNT(CASE WHEN ws.utm_source = "gsearch" THEN ws.website_session_id ELSE NULL END)/COUNT(ws.website_session_id) AS pct_gsearch_traffic,
    COUNT(CASE WHEN ws.utm_source = "bsearch" THEN ws.website_session_id ELSE NULL END)/COUNT(ws.website_session_id) AS pct_bsearch_traffic,
    COUNT(CASE WHEN ws.utm_source IS NULL AND http_referer IS NOT NULL THEN ws.website_session_id ELSE NULL END)/COUNT(ws.website_session_id) AS pct_search_traffic,
    COUNT(CASE WHEN ws.utm_source IS NULL AND http_referer IS NULL THEN ws.website_session_id ELSE NULL END)/COUNT(ws.website_session_id) AS pct_direct_traffic
FROM
    website_sessions ws
        LEFT JOIN
    orders o ON o.website_session_id = ws.website_session_id
WHERE
    ws.created_at < '2012-11-27'
GROUP BY month
ORDER BY start_of_month;

/* 5 - Session to order conversion rates by month.
 I’d like to tell the story of our website performance improvements over the course of the first 8 months. Could you pull session to order conversion rates, by month?
*/

SELECT  YEAR(ws.created_at) AS year,
		MONTHNAME(ws.created_at) AS month,
		MIN(DATE(ws.created_at)) AS start_of_month,
		COUNT(ws.website_session_id) AS sessions, 
		COUNT(o.order_id) AS orders,
        COUNT(o.order_id)/COUNT(ws.website_session_id) AS conversion_rate
FROM website_sessions ws
LEFT JOIN orders o
ON o.website_session_id = ws.website_session_id
GROUP BY month
ORDER BY start_of_month;

/* 6 - Estimating the revenue earned in the period between Jun 19th and Jul 28th
-- For the gsearch lander test, please estimate the revenue that test earned us 
*/

-- first we'll find the first pageview_id where the new lander page was used (first time it was seen by a potential customer)
SELECT MIN(website_pageview_id) as first_lander_pv_id
FROM website_pageviews
WHERE pageview_url = "/lander-1";

SELECT 
    wp.pageview_url AS landing_page,
    COUNT(sub1.sessions) AS sessions, 
    COUNT(o.order_id) AS orders,
    COUNT(o.order_id)/COUNT(sub1.sessions) AS conv_rate
FROM
    (SELECT 
        ws.website_session_id AS sessions,
		MIN(website_pageview_id) AS first_pageview
    FROM
        website_sessions ws
    LEFT JOIN website_pageviews wp ON ws.website_session_id = wp.website_session_id
    WHERE
        ws.created_at < '2012-07-28'
            AND website_pageview_id > 23504 -- first pageview after the creation of the new landing page
            AND utm_source = 'gsearch'
            AND utm_campaign = 'nonbrand'
    GROUP BY ws.website_session_id) AS sub1
		LEFT JOIN
    website_pageviews wp ON sub1.first_pageview = wp.website_pageview_id
        LEFT JOIN
    orders o ON sub1.sessions = o.website_session_id
WHERE
 	wp.pageview_url IN ('/home' , '/lander-1')
GROUP BY 1;

-- We notice a CVR of 31.8% for the original home page, and 40.6% in the new landing page.

-- Calculate the most recent pageview ID of the original homepage (i.e. the last time it was viewed) by gsearch nonbrand traffic
SELECT 
    MAX(wp.website_session_id) AS latest_gsearch_nonbrand_homepage_visit
FROM
    website_pageviews wp
        LEFT JOIN
    website_sessions ws ON wp.website_session_id = ws.website_session_id
WHERE
	pageview_url = "/home"
    AND ws.created_at < "2012-11-27"
	AND utm_source = "gsearch"
    AND utm_campaign = "nonbrand";
    
-- the session ID of the last homepage visit from nonbranded gsearch traffic is: 17145
-- calculating the number of sessions since then
SELECT COUNT(ws.website_session_id) AS sessions
FROM website_sessions ws
WHERE 
	website_session_id > 17145
    AND ws.created_at < "2012-11-27"
	AND utm_source = "gsearch"
    AND utm_campaign = "nonbrand";


/* The difference in CVR was 0.0088, so multiplying it by 22972 gives us about 202 since Jul 28th, so about 4 months
 202 / 4  is roughly 50, so we have 50 more sessions per month after switching to new landing page! */
 
 
/* 7- Create a full conversion funnel for both landing pages in the aforementioned period.
For the landing page test you analyzed previously, it would be great to show a full conversion funnel from each
of the two pages to orders. You can use the same time period you analyzed last time (Jun 19 – Jul 28). */

-- we create another table where we extract how far each session has gotten using flags that we added to them in a subquery
CREATE TEMPORARY TABLE session_funnel_progress
SELECT session_id,
	   MAX(homepage) AS saw_homepage, 
	   MAX(new_lander) AS saw_new_lander,
       MAX(products_page) as reached_products_page,
	   MAX(mr_fuzzy_page) as reached_mr_fuzzy_page, 
       MAX(cart_page) as reached_cart_page,
       MAX(billing_page) as reached_billing_page,
       MAX(shipping_page) as reached_shipping_page,
       MAX(thankyou_page) as reached_thankyou_page
FROM (SELECT
	ws.website_session_id AS session_id, 
    wp.pageview_url, 
    CASE WHEN pageview_url = '/home' THEN 1 ELSE 0 END AS homepage,
    CASE WHEN pageview_url = '/lander-1' THEN 1 ELSE 0 END AS new_lander,
    CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
    CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mr_fuzzy_page, 
    CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
    CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
    CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
    CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
FROM website_sessions ws
	LEFT JOIN website_pageviews wp
		ON ws.website_session_id = wp.website_session_id
WHERE utm_source = 'gsearch' 
	AND utm_campaign = 'nonbrand' 
    AND ws.created_at < '2012-07-28'
		AND ws.created_at > '2012-06-19'
ORDER BY 
	ws.website_session_id,
    wp.created_at) as flagged_sessions
GROUP BY session_id;

-- Now we count how many times the sessions reached each step in the funnel:
CREATE TEMPORARY TABLE funnel_steps_count
SELECT
	CASE 
		WHEN saw_homepage = 1 THEN 'saw_homepage'
        WHEN saw_new_lander = 1 THEN 'saw_new_lander'
        ELSE 'check logic' 
	END AS segment, 
    COUNT(session_id) AS sessions,
    COUNT(CASE WHEN reached_products_page = 1 THEN session_id ELSE NULL END) AS reached_products_page,
    COUNT(CASE WHEN reached_mr_fuzzy_page = 1 THEN session_id ELSE NULL END) AS reached_mr_fuzzy,
    COUNT(CASE WHEN reached_cart_page = 1 THEN session_id ELSE NULL END) AS reached_cart,
    COUNT(CASE WHEN reached_shipping_page = 1 THEN session_id ELSE NULL END) AS reached_shipping,
    COUNT(CASE WHEN reached_billing_page = 1 THEN session_id ELSE NULL END) AS reached_billing,
    COUNT(CASE WHEN reached_thankyou_page = 1 THEN session_id ELSE NULL END) AS reached_thankyou
FROM session_funnel_progress
GROUP BY 1;

-- The final step is to convert the numbers into conversion rates
SELECT  
		CASE 
			WHEN saw_homepage = 1 THEN 'saw_homepage'
			WHEN saw_new_lander = 1 THEN 'saw_new_lander'
			ELSE 'check logic' 
		END AS segment,
		COUNT(CASE WHEN reached_products_page = 1 THEN session_id ELSE NULL END)/COUNT(session_id) AS lander_click_rt,
		COUNT(CASE WHEN reached_mr_fuzzy_page = 1 THEN session_id ELSE NULL END)/COUNT(CASE WHEN reached_products_page = 1 THEN session_id ELSE NULL END) AS products_click_rt,
		COUNT(CASE WHEN reached_cart_page = 1 THEN session_id ELSE NULL END)/COUNT(CASE WHEN reached_mr_fuzzy_page = 1 THEN session_id ELSE NULL END) AS mr_fuzzy_click_rt,
		COUNT(CASE WHEN reached_shipping_page = 1 THEN session_id ELSE NULL END)/COUNT(CASE WHEN reached_cart_page = 1 THEN session_id ELSE NULL END) AS cart_click_rt,
		COUNT(CASE WHEN reached_billing_page = 1 THEN session_id ELSE NULL END)/COUNT(CASE WHEN reached_shipping_page = 1 THEN session_id ELSE NULL END) AS shipping_rt,
		COUNT(CASE WHEN reached_thankyou_page = 1 THEN session_id ELSE NULL END)/COUNT(CASE WHEN reached_billing_page = 1 THEN session_id ELSE NULL END) AS billing_click_rt
FROM session_funnel_progress
GROUP BY 1;

/* 8- Analyze the revenue generated in the test conducted between Sep 10th and Nov 10th between the two billing pages.
I’d love for you to quantify the impact of our billing test, as well. Please analyze the lift generated from the test
(Sep 10 – Nov 10), in terms of revenue per billing page session, and then pull the number of billing page sessions
for the past month to understand monthly impact.*/

SELECT pages,
		COUNT(sessions) AS sessions,
        SUM(price_usd)/COUNT(sessions) AS revenue_per_page
FROM (SELECT wp.website_session_id AS sessions,
	   wp.pageview_url AS pages,
	   o.order_id,
       o.price_usd
FROM website_pageviews wp
LEFT JOIN orders o
ON o.website_session_id = wp.website_session_id
WHERE wp.created_at > "2012-09-10"
	AND wp.created_at < "2012-11-10"
    AND wp.pageview_url IN ("/billing","/billing-2")) AS billing_page_and_order_info
GROUP BY pages;

/* The new billing page gets $31.33, while the old ones gets $22.83
The lift is $8.5 more per session */

-- Counting the web sessions per page in the past month
SELECT COUNT(website_session_id) as sessions_that_reached_billing
FROM website_pageviews
WHERE created_at > "2012-10-27" -- past month
	AND created_at < "2012-11-27"
    AND pageview_url IN ("/billing","/billing-2")

/* We have 1193 sessions that reached billing
Revenue = 1193 * 8.5 = $10140.5 */ 


