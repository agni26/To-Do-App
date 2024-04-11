todo_server <- function(id) {
  
  moduleServer(id, function(input, output, session) {
    
    # Controlling conditional ui parameters - Date
    observeEvent(input$category, {
      updateTabsetPanel(inputId = "params_date", selected = input$category)
    }) 
    
    # Defining Reactive Values 
    tasks <- reactiveVal(dat)
    alert <- reactiveVal(NULL)
    curr_date <- reactiveVal(Sys.Date())
    
    reactive({
      uids <- dat |> 
        filter(next_date < curr_date()) |> 
        mutate(next_date = case_when(
          
        ))
      
      for (id in uids) {
        x <- dat |> 
          filter(uid == id)
      }
      
    })
    
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
                    mutate(Day = weekdays(next_date)) |> 
                    select(Task = title,
                           Details = detail,
                           Type = category,
                           `Due on` = next_date,
                           Day,
                           Actions = button),
                  options = list(
                    fixedColumns = TRUE,
                    autoWidth = TRUE,
                    scrollX = TRUE,
                    columnDefs = list(list(width = '25%', targets = c(0)),
                                      list(width = '50%', targets = c(1))),
                    dom = 'Btsp'),
                  editable = list(target = "cell", disable = list(columns = c(0, 2, 3, 4, 5))),
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
      
      nxt_date = input$date
      
      if(input$date < today()){
        
        if (input$category == "Daily") {
          nxt_date = today()
        }
        else if (input$category == "Monthly") {
          nxt_date = input$date + months(1)
        }
        else if (input$category == "Yearly") {
          nxt_date = input$date + years(1)
        }
      }
      
      dbExecute(con,
                "INSERT INTO todo VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
                list(
                  uuid::UUIDgenerate(TRUE),
                  input$title,
                  input$detail,
                  input$category,
                  FALSE,
                  input$date,
                  nxt_date,
                  Sys.time(),
                  Sys.time())
                )
      
      reset("title")
      reset("detail")
      reset("category")
      reset("date")
      
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