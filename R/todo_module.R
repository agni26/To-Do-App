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
    
    
    # Function to update table with new row
    observeEvent(input$add, {
      
      # Insert new row into the database
      dbExecute(con, 
                "INSERT INTO todo VALUES (?, ?, ?, ?, ?)", 
                list(
                  uuid::UUIDgenerate(TRUE), 
                  input$title, 
                  input$detail,
                  input$category, 
                  FALSE))
      
      # Update the table data
      output$show <- renderDataTable({
        dat <- con |> 
          tbl("todo") |> 
          collect()
        
        dat <- transform(
          dat, 
          Edit = paste0("<button id='edit_", dat$uid, "'>Edit</button>")
        )
        
        dat |> select(Type = category,
                      Task = title,
                      Details = detail,
                      Edit)
      }, escape = FALSE)
    })
    
    # Render the initial table
    output$show <- renderDataTable({
      dat <- con |> 
        tbl("todo") |> 
        collect()
      
      dat <- transform(
        dat, 
        Edit = paste0("<button id='edit_", dat$uid, "'>Edit</button>")
      )
      
      dat |> select(Type = category,
                    Task = title,
                    Details = detail,
                    Edit)
    }, escape = FALSE)
    
  })
}
