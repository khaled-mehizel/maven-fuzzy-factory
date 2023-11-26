# Maven Fuzzy Market Marketing/Web Analysis and Report
 DB Analysis as part of Maven Analytics' Advanced MySQL course.

 The course has the user play the role of a database analyst in a startup ecommerce company named Maven Fuzzy Factory. Responsibilities include optimizing market channels, measuring the impact of new product launches, and generally helping steer the startup to grow as quickly as possible.

The dataset is provided by [Maven Analytics](https://www.mavenanalytics.io). It covers the products and performance of an ecommerce startup.

The goal of this project is to put together a data storytelling report for the board of the company, highlighting the strides that have been made in the 8 months the company has been launched, and emphasizing its rapid growth. As well as showcase the steps taken to improve the website in general.
Note that we are only going to analyze the data up until 2012-11-27 as that's the day we receive the email.

I decided to go the extra mile and visualize it as well! 

# Resources and Tools Used
- MySQL Workbench for the querying of the data.
- Dataset provided in the course in the form of SQL scripts.
- PowerBI for the report building.

# Importing the Dataset
- The preparation file includes a script to change certain settings in MySQL Workbench to not break some date values, and to make the timeouts for the queries less strict just in case my PC decides to be extra slow (it did).
- The other SQL script includes the data itself, as seen in my previous projects, this method allows the data to be imported very quickly.

# Preliminary Check
- The Database has 6 tables, providing information about the user's website sessions, which pages were visited, their orders, the company's products, what items were orders, and what items were refunded.
- There are three sources from where the customer can find the website: "gsearch", "bsearch", and "socialbook"
- There are two marketing campaigns: "brand" and "nonbrand"

# Mid-course Project
### We are to extract certain information in order to tell a story to the board of the Maven Fuzzy Factory, an E-Commerce company that has been live for 8 months. The information required is as follows:
- Monthly trends of the web sessions and orders coming from the "gsearch" channel. (where the potential customer comes from)
- Ditto but separated by campaign.
- Ditto but only the "nonbrand" campaign, separated by device type.
- Ditto but "gsearch" against **each** of the other channels.
- Session to order conversion rates by month.
- Estimate revenue earned by landing page test conducted in the period between Jun 19th and Jul 28th.
- Create a full conversion funnel for both landing pages in the aforementioned period.
- Analyze the revenue generated in the test conducted between Sep 10th and Nov 10th between the two billing pages.

## Monthly Trends of orders and sessions coming from Gsearch:
We extract the month from the "created_at" column, and count the session and order IDs, aggregated by month. I'd include a year column as well, but it's redundant here.

## Monthly Trends of orders and sessions coming from Gsearch seperated by campaign:
Same query as before, except we use **Case Pivoting** to turn branded vs nonbranded into columns rather than keep them as rows, it's a neat trick!
Basically it counts the result of the CASE statement if it satisfies the requirement (the campaign is branded or nonbranded), otherwise it treats it as null.

## Monthly Trends of nonbranded orders and sessions coming from Gsearch seperated by device type:
Same query as the last one, but we'll use **Case Pivoting** with the device type, only paying mind to the searches coming thanks to the nonbranded campaign.

## Comparing Gsearch against each of the other channels:
We use the **Case Pivoting** again, we put the paid traffic coming from Gsearch and Bsearch in seperate categories, as well as the traffic coming in from search engines (non paid), and the traffic coming directly into the site.

## Session to order conversion rates by month.
The conversion rate is the rate at which the website session is successful (order), so to acquire the rate, we aggregate the numbers of sessions, orders, and the rate of orders/sessions, by month.

## Estimate revenue earned by landing page test conducted in the period between Jun 19th and Jul 28th

Using a **subquery** where we determine the first pageview id of every session, we are able to see which page the potential customer has landed on, in the next step.

Using two **LEFT JOINs**, we determine which landing page the customer has landed by joining the "website_pageviews" table, the count of sessions, orders, and the conversion rate per each landing page.

Next, we are to calculate the ID of the last session the original homepage was visited with nonbrand gsearch traffic. To do this we'll need to **LEFT JOIN** the website_pageviews table with the website_sessions ID. We didn't have to do this when we extracted the first pageview ID where the new lander page was visited because there were no constraints on the traffic type.

 The increase of sessions since then (until the 27th of November as stated in the first section), and after some quick math we find that we now get 50 more sessions per months!

    The difference in CVR was 0.0088, so multiplying it by 22972 gives us about 202 since Jul 28th, so about 4 months
    202 / 4  is roughly 50, so we have 50 more sessions per month after switching to the new landing page!


## Create a full conversion funnel for both landing pages in the aforementioned period.
The conversion funnel is how far into the ordering process the session has gotten, from the browsing all the way to the thank-you page.
To accomplish this task, we must divide the query into a few steps:
- First, we extract the sessions in this period that landed in these two pages.
- We add flags using **Case Pivoting** for each session, to show how far into the funnel it has gotten.
- Based on the previous step, we categorize each session on what step in the funnel it reached.
- We then count how many sessions reached each step of the funnel, as well as the full conversion rate, aggregated by the landing pages.

## Analyze the revenue generated in the test conducted between Sep 10th and Nov 10th between the two billing pages.
- We start by creating a subquery that has the needed data ready for us, the session ID, which billing page was used, the order ID and the total of the order, all in the time constraint specified by the CEO.
- Then, we group the sessions and their totals by each billing page. We find that the new billing page has a lift of $8.5 per session.
I actually rewrote this entire query and realized the old one was correct all along

## Calculate the revenue generated in the previous query thanks to this test.
- We count the sessions that reached the order and multiply it by the lift we discovered just now:
    
        $8.5 * 1193 = $10140.5

# Data Modeling
- Extracted all the relevant tables until 2012-11-27.
- Created relationships between the queried data and the lookup tables.

# Visualization
- Extracted each requirement into a CSV file, I'll connect MySQL to PBI eventually I swear.
    - Extracted the funnel one into two for each landing page.
- Linked a previously created calendar table **CALENDAR()**.
- Linked the funnels, **unpivoted** them, and made two conversion funnel visuals, one for each homepage.
- Sorting the axes in Power BI is so unbelievable backwards and unintuitive, it's incredible, but I made it work!
    - Choosing the sorting column in Data View seemingly does nothing, so you have to select the field in the Build-a-Visual pane, select the field you want, the sorting column for it, AND THEN choose what to sort with the axis with on the drop-down menu at the top of the visual! It is 2023, this is terrible design
- Since there is no double funnel in Power BI, I used two funnels for each page and removed the step label on the second one, it's a hack job, but it works.
- Added different line visualizations to show the monthly changes in the conversion rates, numbers of sessions, and numbers of orders based on the CEO's request.
- Kept the calculations at the start static due to the purposes of this report.
- Used a line chart to highlight how the other traffic sources are starting to acquire more traction from GSearch.


# Recap
- Contributed in putting together a very compelling report to the board, showcasing the growth our startup has managed, from conversion funnels to analyzing the effects of the optimization process we put together, like testing new landing and billing pages, increasing the customer's confidence in our website.
- Emphasized the differences between the marketing channels, and the traffic sources separately, to paint a clear picture on where the money should go in terms of paid traffic and advertising campaigns.
- Effectively displayed the fruits of all the labor over the first months of the startup's life, from tweaking the landing and billing pages, as well as adjusting the marketing channels.
- Very likely to secure further funding for future endeavors, new products, new ad campaigns etc.

# My thoughts
This is why I want to work in data for life. This field genuinely interests me, and I love the tools that I can use with it. I think that the website data analysis is quite a different ballgame than HR or Business analyses but I still enjoyed it all the same. <br>
What I also enjoyed very much is seeing the company improve as a result of my and many others' contribution, that was very exciting for me.
