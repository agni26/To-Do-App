todo_ui <- function(id){
  
  fluidPage(
    useShinyjs(),
    
    titlePanel("To-Do App"),
    
    sidebarLayout(
      sidebarPanel(
        textInput(
          NS(id, "title"), 
          "TASK"
        ),
        
        textAreaInput(
          NS(id, "detail"), 
          "DETAILS"
        ),
        
        selectInput(
          NS(id, "category"), 
          "FREQUENCY", 
          choices = c("Once", "Daily", "Weekly", "Monthly", "Yearly")
        ),
        
        actionButton(
          NS(id, "add"), 
          label = "Add",
          icon = shiny::icon("arrow-right"),
          class = "btn-primary"
        )
      ),
      
      mainPanel( 
        DTOutput(NS(id, "show")),
        textOutput(NS(id, "msg"))
      )
    ),
    
    includeScript("www/get_ID.js")
  )
}


todo_server <- function(id){
  
  moduleServer(id, function(input, output, session) {
    
    # Render the initial table
    output$show <- renderDT({
      
      dat <- con |> 
        tbl("todo") |> 
        collect()
      
      if(nrow(dat)>0){
        
        dat <- dat |> 
          mutate(
            Status = case_when(status == FALSE ~ 
                                 paste0("<button class='btn btn-success' 
                                        id='stat_", uid, "' 
                                        onclick='get_id(this.id)'> Done ",
                                        icon("check"),"</button>"),
                               status == TRUE ~ 
                                 paste0("<button class='btn btn-outline-warning' 
                                        id='stat_", uid, "' 
                                        onclick='get_id(this.id)'> Redo",
                                        icon("rotate"),"</button>")),
            Delete = paste0("<button class='action-button btn-danger' 
                          id='del_", uid, "' 
                          onclick='get_id(this.id)'>
                          <i class='fa-solid fa-trash'></i></button>")
          )
        
        datatable(dat |> 
                    select(Status,
                           Task = title,
                           Details = detail,
                           Type = category,
                           Delete),
                  options = list(
                    fixedColumns = TRUE,
                    autoWidth = TRUE,
                    ordering = TRUE,
                    dom = 'Btsp'),
                  editable = TRUE, 
                  rownames = FALSE,
                  escape = FALSE,
                  selection = 'none')
        
      }
    })
    
    # Function to update table with new row
    observeEvent(input$add, {
      
      # Insert new row into the database
      # dbWriteTable(
      #   con,
      #   name = "todo",
      #   value = data.frame(
      #             uid = uuid::UUIDgenerate(TRUE),
      #             title = input$title,
      #             detail = input$detail,
      #             category = input$category,
      #             status = FALSE),
      #   overwrite = FALSE,
      #   append = TRUE
      # )
      
      dbExecute(con,
                "INSERT INTO todo VALUES (?, ?, ?, ?, ?)",
                list(
                  uuid::UUIDgenerate(TRUE),
                  input$title,
                  input$detail,
                  input$category,
                  FALSE))
      
      reset("title")
      reset("detail")
      reset("category")
      
      output$msg <- renderText({
        paste0("Added record")
      })
      
      # Update the table data
      output$show <- renderDT({
        dat <- con |> 
          tbl("todo") |> 
          collect()
        
        dat <- dat |> 
          mutate(
            Status = case_when(status == FALSE ~ 
                                 paste0("<button class='btn btn-success' 
                                        id='stat_", uid, "' 
                                        onclick='get_id(this.id)'> Done ",
                                        icon("check"),"</button>"),
                               status == TRUE ~ 
                                 paste0("<button class='btn btn-outline-warning' 
                                        id='stat_", uid, "' 
                                        onclick='get_id(this.id)'> Redo",
                                        icon("rotate"),"</button>")),
            Delete = paste0("<button class='action-button btn-danger' 
                          id='del_", uid, "' 
                          onclick='get_id(this.id)'>
                          <i class='fa-solid fa-trash'></i></button>")
          )
        
        datatable(dat |> 
                    select(Status,
                           Task = title,
                           Details = detail,
                           Type = category,
                           Delete),
                  options = list(
                    fixedColumns = TRUE,
                    autoWidth = TRUE,
                    ordering = TRUE,
                    dom = 'Btsp'),
                  editable = TRUE, 
                  rownames = FALSE,
                  escape = FALSE,
                  selection = 'none')
        
      })
    })
    
    get_id <- function(id){
      output$msg <- renderText({
        print(paste0("pressed:", input$current_id))
      })
    }
    
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
      
      output$msg <- renderText({
        paste0("Updated record")
      })
      
      output$show <- renderDT({
        
        dat <- con |> 
          tbl("todo") |> 
          collect()
        
        dat <- dat |> 
          mutate(
            Status = case_when(status == FALSE ~ 
                                 paste0("<button class='btn btn-success' 
                                        id='stat_", uid, "' 
                                        onclick='get_id(this.id)'> Done ",
                                        icon("check"),"</button>"),
                               status == TRUE ~ 
                                 paste0("<button class='btn btn-outline-warning' 
                                        id='stat_", uid, "' 
                                        onclick='get_id(this.id)'> Redo",
                                        icon("rotate"),"</button>")),
            Delete = paste0("<button class='action-button btn-danger' 
                          id='del_", uid, "' 
                          onclick='get_id(this.id)'>
                          <i class='fa-solid fa-trash'></i></button>")
          )
        
        datatable(dat |> 
                    select(Status,
                           Task = title,
                           Details = detail,
                           Type = category,
                           Delete),
                  options = list(
                    fixedColumns = TRUE,
                    autoWidth = TRUE,
                    ordering = TRUE,
                    dom = 'Btsp'),
                  editable = TRUE, 
                  rownames = FALSE,
                  escape = FALSE,
                  selection = 'none',
        )
        
      })
    })
    
    observeEvent(input$current_id, {
      output$msg <- renderText({
        paste0("pressed:", input$current_id)
      })
    })
    
    output$msg <- renderText({
      paste0("pressed:", input$current_id)
    })
    
  })
}
