# maven-fuzzy-market
 DB Analysis as part of Maven Analytics' Advanced MySQL course.

 The course has the user play the role of a database analyst in a startup ecommerce company named Maven Fuzzy Factory. Responsibilities include optimizing market channels, measuring the impact of new product launches, and generally helping steer the startup to grow as quickly as possible.

The dataset is provided by [Maven Analytics](https://www.mavenanalytics.io). It covers the products and performance of an ecommerce startup.

# Resources and Tools Used
- MySQL Workbench for the querying of the data.
- Dataset provided in the course in the form of SQL scripts.

# Importing the Dataset
- The preparation file includes a script to change certain settings in MySQL Workbench to not break some date values, and to make the timeouts for the queries less strict just in case my PC decides to be extra slow (it did).
- The other SQL script includes the data itself, as seen in my previous projects, this method allows the data to be imported very quickly.

# Preliminary Check
- The Database has 6 tables, providing information about the user's website sessions, which pages were visited, their orders, the company's products, what items were orders, and what items were refunded.

