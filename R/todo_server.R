todo_server <- function(id) {
  
  moduleServer(id, function(input, output, session) {
    
    # Controlling conditional ui parameters - Date
    observeEvent(input$category, {
      updateTabsetPanel(inputId = "params_date", selected = input$category)
    }) 
    
    # Defining Reactive Values 
    tasks <- reactiveVal(dat)
    alert <- reactiveVal(NULL)
    
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
                    <button class='btn btn-success btn-sm' id='stat_", uid, "' 
                      onclick='get_id(this.id)'>", icon("check"),"</button>
                    <button class='btn btn-danger btn-sm' id='del_", uid, "' 
                      onclick='get_id(this.id)'>",icon("trash"),"</button>"
                ),
              status == TRUE ~ 
                paste0(
                  "<div class = 'btn-group'>
                    <button class='btn btn-warning btn-sm' id='stat_", uid, "' 
                      onclick='get_id(this.id)'>",icon("rotate"),"</button>
                    <button class='btn btn-danger btn-sm' id='del_", uid, "' 
                      onclick='get_id(this.id)'>",icon("trash"),"</button>")))
        
        datatable(dat |> 
                    select(Task = title,
                           Details = detail,
                           Type = category,
                           Actions = button),
                  options = list(
                    fixedColumns = TRUE,
                    autoWidth = TRUE,
                    scrollX = TRUE,
                    columnDefs = list(list(width = '25%', targets = c(0)),
                                      list(width = '60%', targets = c(1)),
                                      list(width = '5%', targets = c(2)),
                                      list(width = '8%', targets = c(3))),
                    dom = 'Btsp'),
                  editable = list(target = "cell", disable = list(columns = c(0, 2, 3))),
                  rownames = FALSE,
                  escape = FALSE,
                  selection = 'none')
      }
    })
    
    # Render Output Notification
    reactive({
      showNotification(alert(), closeButton = TRUE)
    })
    
    # Function to update table with new row
    observeEvent(input$add, {
      
      st_date = input$date
      wk_day = input$day
      nxt_date = NULL
      
      
      
      if(input$category == "Daily"){
        nxt_date = Sys.Date() + 1
      }
      if(input$category == "Weekly"){
        if(week == weekdays(Sys.Date()))
        nxt_date = Sys.Date()
      }
      
      
      
      dbExecute(con,
                "INSERT INTO todo VALUES (?, ?, ?, ?, ?, ?, ?, ?, ? ,?)",
                list(
                  uuid::UUIDgenerate(TRUE),
                  input$title,
                  input$detail,
                  input$category,
                  FALSE,
                  ))
      
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
      
      dat[row, clmn] <- val
      
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