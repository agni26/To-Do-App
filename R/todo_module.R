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
      output$show <- renderDT({
        dat <- con |> 
          tbl("todo") |> 
          collect()
        
        dat <- transform(
          dat,
          Status = paste0("<input type='radio name='radio_", dat$uid, "' value='", dat$status, "'/>"),
          Delete = paste0("<button id='del_", dat$uid, "'><i class='fa-solid fa-trash'></i></button>")
        )
        
        datatable(dat |> 
                    select(Status,
                           Task = title,
                           Details = detail,
                           Type = category,
                           Delete), 
                  options = list(dom = 't'), 
                  editable = TRUE, 
                  rownames = FALSE,
                  escape = FALSE,
                  selection = 'none')
        
      })
    })
    
    # Render the initial table
    output$show <- renderDT({
      
      dat <- con |> 
        tbl("todo") |> 
        collect()
      
      dat <- transform(
        dat,
        Status = paste0("<input type='radio name='radio_", dat$uid, "' value='", dat$status, "'/>"),
        Delete = paste0("<button id='del_", dat$uid, "'><i class='fa-solid fa-trash'></i></button>")
      )
      
      datatable(dat |> 
                  select(Status,
                         Task = title,
                         Details = detail,
                         Type = category,
                         Delete), 
                options = list(dom = 't'), 
                editable = TRUE, 
                rownames = FALSE,
                escape = FALSE,
                selection = 'none')
      
    })
    
    observeEvent(input$show_cell_edit, {
      
      dat <- con |> 
        tbl("todo") |> 
        collect()
      
      row  <- input$show_cell_edit$row
      clmn <- input$show_cell_edit$col + 1
      val  <- input$show_cell_edit$value
      
      dat[row, clmn] <- val
      
      dbWriteTable(
        con,
        name = "todo",
        value = dat,
        overwrite = TRUE,
        append = FALSE
      )
      
      output$show <- renderDT({
        
        dat <- con |> 
          tbl("todo") |> 
          collect()
        
        dat <- transform(
          dat,
          Status = paste0("<input type='radio name='radio_", dat$uid, "' value='", dat$status, "'/>"),
          Delete = paste0("<button id='del_", dat$uid, "'><i class='fa-solid fa-trash'></i></button>")
        )
        
        datatable(dat |> 
                    select(Status,
                           Task = title,
                           Details = detail,
                           Type = category,
                           Delete), 
                  options = list(dom = 't'), 
                  editable = TRUE, 
                  rownames = FALSE,
                  escape = FALSE,
                  selection = 'none')
        
      })
    })
    
  })
}
