todo_add <- function(id, input){
  
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
  
}