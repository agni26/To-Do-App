library(duckdb)
library(tibble)

con <- dbConnect(duckdb(), "data/todo.duckdb")

# Drop the table if it already exists
dbExecute(con, "DROP TABLE IF EXISTS todo")

create_query = "CREATE TABLE todo (
  uid                             VARCHAR PRIMARY KEY,
  title                           VARCHAR,
  detail                          VARCHAR,
  category                        VARCHAR,
  status                          BOOLEAN,
  start_date                      DATETIME,
  days_of_week                    INTEGER[],
  next_date                       DATETIME,
  created_on                      DATETIME,
  modified_on                     DATETIME
)"

# Execute the query created above
dbExecute(con, create_query)

as_datetime(today())

# Check table structure
dbGetQuery(con, "SELECT * FROM todo")

# List tables to confirm 'todo' table exists
dbListTables(con)

# Disconnect from DB
dbDisconnect(con, shutdown=TRUE)