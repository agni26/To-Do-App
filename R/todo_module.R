todo_ui <- function(id){
  
  fluidPage(
    column(3, 
           textInput(
             NS(id, "title"), 
             "Add a task Title!"
           ),
           
           textInput(
             NS(id, "detail"), 
             "Add task Details"
           ),
           
           selectInput(
             NS(id, "category"), 
             "Select task category", 
             choices = c("daily", "weekly", "monthly", "once")
           ),
           
           actionButton(
             NS(id, "add"), 
             "Add Task!"
           )
    ), 
    
    column(9, 
           tableOutput(
             NS(id, "show")
           )
    )
  )
}


todo_server <- function(id){
  
  moduleServer(id, function(input, output, session) {
    
    dataframe <- eventReactive(input$add ,{
      dat |> add_row(uid = "1",
                     title = input$title,
                     detail = input$detail,
                     status = FALSE
      )
    })
    
    output$show <- renderTable({
      dataframe()
    })
    
    # observeEvent(input$add, {
    #   
    #   con <- dbConnect(duckdb(), "data/todo.duckdb")
    #   
    #   
    #   
    #   DBI::dbWriteTable(
    #     con,
    #     name = "todo",
    #     value = dat,
    #     overwrite = TRUE,
    #     append = TRUE
    #   )
    #   
    #   dbDisconnect(con, shutdown=TRUE)
    # })
    
  })
}
