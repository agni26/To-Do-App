todo_ui <- function(id){
  
  fluidPage(
    column(3, 
           textInput(
             NS(id, "title"), 
             "Add a task Title!"
           ),
           
           textAreaInput(
             NS(id, "detail"), 
             "Add task Details"
           ),
           
           selectInput(
             NS(id, "category"), 
             "Select task category", 
             choices = c("Once", "Daily", "Weekly", "Monthly")
           ),
           
           actionButton(
             NS(id, "add"), 
             "Add Task"
           )
    ), 
    
    column(9, DTOutput(NS(id, "show"))
    )
  )
}


todo_server <- function(id){
  
  moduleServer(id, function(input, output, session) {
    
    tasks <- eventReactive(input$add ,{
      
      # insert two items into the table
      dbExecute(con, 
                "INSERT INTO todo VALUES (?, ?, ?, ?)", 
                list(
                  uuid::UUIDgenerate(TRUE), 
                  input$title, 
                  input$detail,
                  input$category, 
                  FALSE))
      
      dat <- con |> 
        tbl("todo") |> 
        select(Type = category,
               Task = title,
               Details = detail) |> 
        collect()
        
    })
    
    output$show <- renderDT({
      tasks()
    })
    
  })
}
