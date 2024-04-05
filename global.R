# Library in packages used in this application
library(shiny)
library(DT)
library(DBI)
library(duckdb)
library(shinyjs)
library(dplyr)
library(dbplyr)
library(bslib)
library(shinycssloaders)

db_config <- config::get()$db

# Create database connection
con <- dbConnect(
  duckdb(),
  db_config$dbname
)

dat <- dbGetQuery(con, "SELECT * FROM todo")

# Stop database connection when application stops
shiny::onStop(function() {
  dbDisconnect(con, shutdown=TRUE)
})

# Turn off scientific notation
options(scipen = 999)
options(shiny.reactlog=TRUE) 

# Set spinner type (for loading)
options(spinner.type = 8)