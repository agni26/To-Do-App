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
)"

# Execute the query created above
dbExecute(con, create_query)

dbExecute(con, "DELETE From todo")

# retrieve the items again
dat <- dbGetQuery(con, "SELECT * FROM todo")

# dat$uid <- uuid::UUIDgenerate(n = nrow(dat))

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
