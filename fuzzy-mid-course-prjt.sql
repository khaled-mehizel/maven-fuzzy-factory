-- 1- Counting the number of sessions and orders per month coming from "gsearch"-------------------------------------------------------
-- "Gsearch seems to be the biggest driver of our business. Could you pull monthly trends for gsearch sessions and orders so that we can showcase the growth there?-------------

SELECT 
    MONTHNAME(ws.created_at) AS month,
    COUNT(ws.website_session_id) AS sessions,
    COUNT(o.order_id) AS orders
FROM
    website_sessions ws
        LEFT JOIN
    orders o ON o.website_session_id = ws.website_session_id
WHERE
    ws.utm_source = 'gsearch'
        AND ws.created_at < '2012-11-27'
GROUP BY month
ORDER BY start_of_month;

-- 2- Ditto but separated by campaign.
-- Next, it would be great to see a similar monthly trend for Gsearch, but this time splitting out nonbrand and brand campaigns separately. I am wondering if brand is picking up at all. If so, this is a good story to tell.
SELECT 
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

-- 3-- Ditto but only the "nonbrand" campaign, separated by device type.
-- While we’re on Gsearch, could you dive into nonbrand, and pull monthly sessions and orders split by device type? I want to flex our analytical muscles a little and show the board we really know our traffic sources. 

SELECT 
    MONTHNAME(ws.created_at) AS month,
    MIN(DATE(ws.created_at)) AS start_of_month,
	COUNT(CASE WHEN ws.device_type = "mobile" THEN ws.website_session_id ELSE NULL END) AS mobile_sessions,
    COUNT(CASE WHEN ws.device_type = "mobile" THEN o.order_id ELSE NULL END) AS mobile_orders,
    COUNT(CASE WHEN ws.device_type = "desktop" THEN ws.website_session_id ELSE NULL END) AS desktop_sessions,
    COUNT(CASE WHEN ws.device_type = "desktop" THEN o.order_id ELSE NULL END) AS desktop_orders,
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

-- 4- Ditto but "gsearch" against the rest of the channels.
-- I’m worried that one of our more pessimistic board members may be concerned about the large % of traffic from Gsearch. Can you pull monthly trends for Gsearch, alongside monthly trends for each of our other channels?
SELECT 
    MONTHNAME(ws.created_at) AS month,
    MIN(DATE(ws.created_at)) AS start_of_month,
	COUNT(CASE WHEN ws.utm_source = "gsearch" THEN ws.website_session_id ELSE NULL END) AS gsearch_sessions,
    COUNT(CASE WHEN ws.utm_source = "gsearch" THEN o.order_id ELSE NULL END) AS gsearch_orders,
    COUNT(CASE WHEN ws.utm_source <> "gsearch" THEN ws.website_session_id ELSE NULL END) AS non_gsearch_sessions,
    COUNT(CASE WHEN ws.utm_source <> "gsearch" THEN o.order_id ELSE NULL END) AS non_gsearch_orders,
    COUNT(ws.website_session_id) AS total_sessions,
    COUNT(o.order_id) AS total_orders,
    COUNT(CASE WHEN ws.utm_source = "gsearch" THEN ws.website_session_id ELSE NULL END)/COUNT(ws.website_session_id) AS "%_of_sessions",
    COUNT(CASE WHEN ws.utm_source = "gsearch" THEN o.order_id ELSE NULL END)/COUNT(o.order_id) AS "%_of_orders"
FROM
    website_sessions ws
        LEFT JOIN
    orders o ON o.website_session_id = ws.website_session_id
WHERE
    ws.created_at < '2012-11-27'
GROUP BY month
ORDER BY start_of_month;