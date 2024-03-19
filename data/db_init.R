# library(RSQLite)
library(duckdb)
library(tibble)

# # Create a connection object with SQLite
# conn <- dbConnect(
#   RSQLite::SQLite(),
#   "data/todo.sqlite3"
# )

conn <- dbConnect(duckdb(), "data/todo.duckdb")

duckdb_register(conn, "iris", iris)

query <- r'(
SELECT count(*) AS num_observations,
max("Sepal.Width") AS max_width,
max("Petal.Length") AS max_petal_length
FROM iris
WHERE "Sepal.Length" > 5
GROUP BY ALL
)'

dbGetQuery(con, query)

# Create a query to prepare the 'mtcars' table with additional 'uid', 'id',
# & the 4 created/modified columns
create_todo_query = "CREATE TABLE todo (
  uid                             TEXT PRIMARY KEY,
  name                            TEXT
)"

# dbExecute() executes a SQL statement with a connection object
# Drop the table if it already exists
dbExecute(conn, "DROP TABLE IF EXISTS todo")
# Execute the query created above
dbExecute(conn, create_todo_query)

dbExecute(conn, "select * from todo")

dbExecute(conn, "INSERT into todo VALUES (\"anuvind\", \"Anuvind Singh\")")


# Read in the RDS file created in 'data_prep.R'
dat <- readRDS("01_traditional/data_prep/prepped/mtcars.RDS")

# add uid column to the `dat` data frame
dat$uid <- uuid::UUIDgenerate(n = nrow(dat))

# reorder the columns
dat <- dat %>%
  select(uid, everything())

# Fill in the SQLite table with the values from the RDS file
DBI::dbWriteTable(
  conn,
  name = "mtcars",
  value = dat,
  overwrite = FALSE,
  append = TRUE
)

# List tables to confirm 'mtcars' table exists
dbListTables(conn)

# disconnect from SQLite before continuing
dbDisconnect(conn)
