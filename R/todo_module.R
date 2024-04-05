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
    
    # Defining Reactive Values 
    tasks <- reactiveVal(con |> tbl("todo") |> collect())
    alert <- reactiveVal("Connected")
    
    # Render Output Table
    output$show <- renderDT({
      dat <- tasks()
      
      if(nrow(dat)>0){
        dat <- dat |> 
          mutate(
            button = case_when(
              status == FALSE ~ 
                paste0(
                  "<div class = 'btn-group'>
                    <button class='btn btn-success' id='stat_", uid, "' 
                      onclick='get_id(this.id)'>",icon("check"),"</button>
                    <button class='btn btn-danger' id='del_", uid, "' 
                      onclick='get_id(this.id)'>",icon("trash"),"</button>"
                ),
              status == TRUE ~ 
                paste0(
                  "<div class = 'btn-group'>
                    <button class='btn btn-warning' id='stat_", uid, "' 
                      onclick='get_id(this.id)'>",icon("rotate"),"</button>
                    <button class='btn btn-danger' id='del_", uid, "' 
                      onclick='get_id(this.id)'>",icon("trash"),"</button>")))
        
        datatable(dat |> 
                    select(Task = title,
                           Details = detail,
                           Type = category,
                           Actions = button),
                  options = list(
                    fixedColumns = TRUE,
                    autoWidth = TRUE,
                    dom = 'Btsp'),
                  editable = list(target = "cell", disable = list(columns = c(0, 2, 3))),
                  rownames = FALSE,
                  escape = FALSE,
                  selection = 'none')
      }
    })
    
    # Render Output Message
    output$msg <- renderText({
      alert()
    })
    
    # Function to update table with new row
    observeEvent(input$add, {
      
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
      
      alert("Added Task")
      
      # Update the table data
      tasks(con |> 
              tbl("todo") |> 
              collect())
      
    })
    
    observeEvent(input$show_cell_edit, {
      
      dat <- con |> 
        tbl("todo") |> 
        collect()
      
      row  <- input$show_cell_edit$row
      clmn <- input$show_cell_edit$col +2
      val  <- input$show_cell_edit$value
      
      print(row)
      print(clmn)
      print(val)
      
      print(dat[row, clmn])
      
      dat[row, clmn] <- val
      
      print(dat[row, clmn])
      
      
      dbWriteTable(
        con,
        name = "todo",
        value = dat,
        overwrite = TRUE,
        append = FALSE
      )
      
      alert("Updated record")
      
      tasks(con |> 
              tbl("todo") |> 
              collect())
    })
    
    observeEvent(input$current_id, {
      
      id <- unlist(strsplit(input$current_id, "_"))
      id2 <- id[2]
      
      new_status <- !as.logical(
        con |> 
          tbl("todo") |> 
          filter(uid == id2) |>
          select(status) |>
          collect()
      )
      
      if(id[1] == "stat"){
        dbExecute(con,
                  "UPDATE todo SET status = ? WHERE uid = ?",
                  list(
                    new_status,
                    id2))
        
        alert("Updated Status")
      }
      
      if(id[1] == "del"){
        dbExecute(con,
                  "DELETE FROM todo WHERE uid = ?",
                  id2)
        
        alert("Deleted Task")
      }
      
      tasks(con |> 
              tbl("todo") |> 
              collect())
    })
  })
}
