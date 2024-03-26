fluidPage(
  column(3, 
    textInput("title", "Add a task Title!"),
    textInput("detail", "Add task Details"),
    selectInput("category", "Select task category", choices = c("daily", "weekly", "monthly", "immediate")),
    actionButton("add", "Add Task!")
  ), 
  column(9, 
    tableOutput("show")
  )
)
