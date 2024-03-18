#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

function(input, output, session) {
  
  # Use session$userData to store user data that will be needed throughout
  # the Shiny application
  session$userData$email <- 'shivanshagn@gmail.com'
  
  # Call the server function portion of the `cars_table_module.R` module file
  callModule(
    cars_table_module,
    "cars_table"
  )
}
