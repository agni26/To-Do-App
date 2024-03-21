library(duckdb)
library(tibble)

con <- dbConnect(duckdb(), "data/todo.duckdb")

# Drop the table if it already exists
dbExecute(con, "DROP TABLE IF EXISTS todo")

create_query = "CREATE TABLE todo (
  uid                             VARCHAR PRIMARY KEY,
  task                            VARCHAR,
  status                          BOOLEAN,
  created_at                      DATETIME,
  created_by                      VARCHAR,
  modified_at                     DATETIME,
  modified_by                     VARCHAR
)"

# Execute the query created above
dbExecute(con, create_query)

# insert two items into the table
dbExecute(con, "INSERT INTO todo VALUES
          ('001', 'Attend meeting at 4', FALSE, NULL, NULL, NULL, NULL),
          ('002', 'Go for Grocery shopping', FALSE, NULL, NULL, NULL, NULL)")

# retrieve the items again
dat <- dbGetQuery(con, "SELECT * FROM todo")

dat$uid <- uuid::UUIDgenerate(n = nrow(dat))

# reorder the columns
dat <- dat |> 
  select(uid, everything())

DBI::dbWriteTable(
  con,
  name = "todo",
  value = dat,
  overwrite = FALSE,
  append = TRUE
)

# List tables to confirm 'todo' table exists
dbListTables(con)

# disconnect from duckdb before continuing
dbDisconnect(con, shutdown=TRUE)

