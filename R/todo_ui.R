todo_ui <- function(id){
  
  page_sidebar(
    
    useShinyjs(),
    includeScript("www/get_ID.js"),
    
    title = "To-Do App",
    fillable = TRUE,
    fluid = TRUE,
    collapsible = TRUE,
    fillable_mobile = TRUE,
    #theme = theme,
    nav_spacer(),
    
    sidebar = sidebar(
      width = "25%",
      
      textInput(NS(id, "title"), "TASK"),
      
      textAreaInput(NS(id, "detail"), "DETAILS"),
      
      selectInput(
        NS(id, "category"), 
        "FREQUENCY", 
        choices = c("Once", "Daily", "Weekly", "Monthly", "Yearly")
      ),
      
      tabsetPanel(
        id = NS(id,"params"),
        type = "hidden",
        
        tabPanel("Once", dateInput(NS(id, "date"), "DATE")),
        
        tabPanel("Daily", dateInput(NS(id, "date"), "START DATE")),
        
        tabPanel("Weekly", checkboxGroupInput(
          NS(id, "day"), "WEEKDAYS", 
          choices = c("Monday", "Tuesday", "Wednesday", "Thursday", 
                      "Friday", "Saturday", "Sunday"))),
        
        tabPanel("Monthly", dateInput(NS(id, "date"), "START DATE")),
        
        tabPanel("Yearly", dateInput(NS(id, "date"), "START DATE"))
      ),
      
      actionButton(
        NS(id, "add"), 
        label = " Add",
        icon = shiny::icon("arrow-right"),
        class = "btn-primary"
      )
    ),
    navset_bar(
      title = "Tasks",
      nav_spacer(),
      
      nav_panel(
        title = "Upcoming",
        icon = icon("house"),
        
        withSpinner(DTOutput(NS(id, "show"))),
        textOutput(NS(id, "msg"))
      ),
      
      nav_panel(
        title = "Pending",
        icon = icon("list"),
        
        "hi hi"
      ),
      
      nav_panel(
        title = "Completed",
        icon = icon("list-check"),
        
        "hi hi"
      )
    )
  )
}