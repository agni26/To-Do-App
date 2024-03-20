#' Todo Table Module UI
#'
#' The UI portion of the module for displaying the todo datatable
#'
#' @importFrom shiny NS tagList fluidRow column actionButton tags
#' @importFrom DT DTOutput
#' @importFrom shinycssloaders withSpinner
#'
#' @param id The id for this module
#'
#' @return a \code{shiny::\link[shiny]{tagList}} containing UI elements
#'
todo_table_module_ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    fluidRow(
      column(
        width = 2,
        actionButton(
          ns("add_task"),
          "Add",
          class = "btn-success",
          style = "color: #fff;",
          icon = icon('plus'),
          width = '100%'
        ),
        tags$br(),
        tags$br()
      )
    ),
    fluidRow(
      column(
        width = 12,
        title = "To Do List",
        DTOutput(ns('todo_table')) |> 
          withSpinner(),
        tags$br(),
        tags$br()
      )
    ),
    tags$script(src = "todo_table_module.js"),
    tags$script(paste0("todo_table_module_js('", ns(''), "')"))
  )
}

#' todo Table Module Server
#'
#' The Server portion of the module for displaying the mtcars datatable
#'
#' @importFrom shiny reactive reactiveVal observeEvent req callModule eventReactive
#' @importFrom DT renderDT datatable replaceData dataTableProxy
#' @importFrom dplyr tbl collect mutate arrange select filter pull
#' @importFrom purrr map_chr
#' @importFrom tibble tibble
#'
#' @param None
#'
#' @return None

todo_table_module <- function(input, output, session) {
  
  # trigger to reload data from the "todo" table
  session$userData$todo_trigger <- reactiveVal(0)
  
  # Read in "todo" table from the database
  todo <- reactive({
    session$userData$todo_trigger()
    
    out <- NULL
    tryCatch({
      out <- con |> 
        tbl('todo') |> 
        collect() |> 
        mutate(
          created_at = as.POSIXct(created_at, tz = "UTC"),
          modified_at = as.POSIXct(modified_at, tz = "UTC")
        ) |> 
        arrange(desc(modified_at))
    }, error = function(err) {
      
      
      msg <- "Database Connection Error"
      # print `msg` so that we can find it in the logs
      print(msg)
      # print the actual error to log it
      print(error)
      # show error `msg` to user.  User can then tell us about error and we can
      # quickly identify where it cam from based on the value in `msg`
      showToast("error", msg)
    })
    
    out
  })
  
  
  todo_table_prep <- reactiveVal(NULL)
  
  observeEvent(todo(), {
    out <- todo()
    
    ids <- out$uid
    
    actions <- purrr::map_chr(ids, function(id_) {
      paste0(
        '<div class="btn-group" style="width: 75px;" role="group" aria-label="Basic example">
          <button class="btn btn-primary btn-sm edit_btn" data-toggle="tooltip" data-placement="top" title="Edit" id = ', id_, ' style="margin: 0"><i class="fa fa-pencil-square-o"></i></button>
          <button class="btn btn-danger btn-sm delete_btn" data-toggle="tooltip" data-placement="top" title="Delete" id = ', id_, ' style="margin: 0"><i class="fa fa-trash-o"></i></button>
        </div>'
      )
    })
    
    # Remove the `uid` column. We don't want to show this column to the user
    out <- out |> 
      select(-uid)
    
    # Set the Action Buttons row to the first column of the `todo` table
    out <- cbind(
      tibble(" " = actions),
      out
    )
    
    if (is.null(todo_table_prep())) {
      # loading data into the table for the first time, so we render the entire table
      # rather than using a DT proxy
      todo_table_prep(out)
      
    } else {
      
      # table has already rendered, so use DT proxy to update the data in the
      # table without rerendering the entire table
      replaceData(todo_table_proxy, out, resetPaging = FALSE, rownames = FALSE)
      
    }
  })
  
  output$todo_table <- renderDT({
    req(todo_table_prep())
    out <- todo_table_prep()
    
    datatable(
      out,
      rownames = FALSE,
      colnames = c('Task', 'Created At',
                   'Created By', 'Modified At', 'Modified By'),
      selection = "none",
      class = "compact stripe row-border nowrap",
      # Escape the HTML in all except 1st column (which has the buttons)
      escape = -1,
      extensions = c("Buttons"),
      options = list(
        scrollX = TRUE,
        dom = 'Bftip',
        buttons = list(
          list(
            extend = "excel",
            text = "Download",
            title = paste0("todo-", Sys.Date()),
            exportOptions = list(
              columns = 1:(length(out) - 1)
            )
          )
        ),
        columnDefs = list(
          list(targets = 0, orderable = FALSE)
        ),
        drawCallback = JS("function(settings) {
          // removes any lingering tooltips
          $('.tooltip').remove()
        }")
      )
    ) |> 
      formatDate(
        columns = c("created_at", "modified_at"),
        method = 'toLocaleString'
      )
    
  })
  
  todo_table_proxy <- DT::dataTableProxy('todo_table')
  
  callModule(
    todo_edit_module,
    "add_task",
    task_title = "Add Task",
    task_to_edit = function() NULL,
    modal_trigger = reactive({input$add_task})
  )
  
  task_to_edit <- eventReactive(input$task_id_to_edit, {
    
    todo() |> 
      filter(uid == input$task_id_to_edit)
  })
  
  callModule(
    todo_edit_module,
    "edit_task",
    task_title = "Edit Task",
    task_to_edit = task_to_edit,
    modal_trigger = reactive({input$task_id_to_edit})
  )
  
  task_to_delete <- eventReactive(input$task_id_to_delete, {
    
    todo() |> 
      filter(uid == input$task_id_to_delete) |> 
      as.list()
  })
  
  callModule(
    todo_delete_module,
    "delete_task",
    task_title = "Delete Task",
    task_to_delete = task_to_delete,
    modal_trigger = reactive({input$task_id_to_delete})
  )
  
}
