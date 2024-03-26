function(input, output, session) {
  
  dataframe <- eventReactive(input$add ,{
    dat |> add_row(
      uid = "1",
      title = input$title,
      detail = input$detail,
      status = FALSE
    )
  })
  
  output$show <- renderTable({
    dataframe()
  })
  
}
