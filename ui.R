#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

fluidPage(
  
  shinyFeedback::useShinyFeedback(),
  shinyjs::useShinyjs(),
  
  # Application Title
  titlePanel(
    h1("To-Do Application", align = 'center'),
    windowTitle = "To-Do App"
  ),
  todo_table_module_ui("cars_table")
)