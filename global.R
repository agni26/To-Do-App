# Library in packages used in this application
library(shiny)
library(DT)
library(DBI)
library(duckdb)
library(shinyjs)
library(dplyr)
library(dbplyr)

db_config <- config::get()$db

# Create database connection
con <- dbConnect(
  duckdb(),
  dbname = db_config$dbname
)

# Stop database connection when application stops
shiny::onStop(function() {
  dbDisconnect(con, shutdown=TRUE)
})

# Turn off scientific notation
options(scipen = 999)

# Set spinner type (for loading)
options(spinner.type = 8)
