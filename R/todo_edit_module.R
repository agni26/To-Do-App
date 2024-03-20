
#' Car Add & Edit Module
#'
#' Module to add & edit cars in the mtcars database file
#'
#' @importFrom shiny observeEvent showModal modalDialog removeModal fluidRow column textInput numericInput selectInput modalButton actionButton reactive eventReactive
#' @importFrom shinyFeedback showFeedbackDanger hideFeedback showToast
#' @importFrom shinyjs enable disable
#' @importFrom lubridate with_tz
#' @importFrom uuid UUIDgenerate
#' @importFrom DBI dbExecute
#'
#' @param task_title string - the title for the modal
#' @param task_to_edit reactive returning a 1 row data frame of the car to edit
#' from the "mt_cars" table
#' @param modal_trigger reactive trigger to open the modal (Add or Edit buttons)
#'
#' @return None
#'
todo_edit_module <- function(input, output, session, task_title, task_to_edit, modal_trigger) {
  ns <- session$ns

  observeEvent(modal_trigger(), {
    hold <- task_to_edit()

    showModal(
      modalDialog(
        fluidRow(
          column(
            width = 6,
            textInput(
              ns("model"),
              'Model',
              value = ifelse(is.null(hold), "", hold$model)
            )
          )
        ),
        title = task_title,
        size = 'm',
        footer = list(
          modalButton('Cancel'),
          actionButton(
            ns('submit'),
            'Submit',
            class = "btn btn-primary",
            style = "color: white"
          )
        )
      )
    )

    # Observe event for "Model" text input in Add/Edit Car Modal
    # `shinyFeedback`
    observeEvent(input$model, {
      if (input$model == "") {
        shinyFeedback::showFeedbackDanger(
          "model",
          text = "Must enter Task"
        )
        shinyjs::disable('submit')
      } else {
        shinyFeedback::hideFeedback("model")
        shinyjs::enable('submit')
      }
    })

  })





  edit_todo_dat <- reactive({
    hold <- task_to_edit()

    out <- list(
      uid = if (is.null(hold)) NA else hold$uid,
      data = list(
        "task" = input$model
        # "mpg" = input$mpg,
        # "cyl" = input$cyl,
        # "disp" = input$disp,
        # "hp" = input$hp,
        # "drat" = input$drat,
        # "wt" = input$wt,
        # "qsec" = input$qsec,
        # "vs" = input$vs,
        # "am" = input$am,
        # "gear" = input$gear,
        # "carb" = input$carb
      )
    )

    time_now <- as.character(lubridate::with_tz(Sys.time(), tzone = "UTC"))

    if (is.null(hold)) {
      # adding a new car

      out$data$created_at <- time_now
      out$data$created_by <- session$userData$email
    } else {
      # Editing existing car

      out$data$created_at <- as.character(hold$created_at)
      out$data$created_by <- hold$created_by
    }

    out$data$modified_at <- time_now
    out$data$modified_by <- session$userData$email

    out
  })

  validate_edit <- eventReactive(input$submit, {
    dat <- edit_todo_dat()

    # Logic to validate inputs...

    dat
  })

  observeEvent(validate_edit(), {
    removeModal()
    dat <- validate_edit()

    tryCatch({

      if (is.na(dat$uid)) {
        # creating a new car
        uid <- uuid::UUIDgenerate()

        dbExecute(
          con,
          "INSERT INTO todo (uid, task, false, created_at, created_by, modified_at, modified_by) VALUES
          ($1, $2, $3, $4, $5, $6, $7)",
          params = c(
            list(uid),
            unname(dat$data)
          )
        )
      } else {
        # editing an existing car
        dbExecute(
          con,
          "UPDATE todo SET task=$1, false, created_at=$2, created_by=$3,
          modified_at=$4, modified_by=$5 WHERE uid=$6",
          params = c(
            unname(dat$data),
            list(dat$uid)
          )
        )
      }

      session$userData$todo_trigger(session$userData$todo_trigger() + 1)
      showToast("success", paste0(task_title, " Successs"))
    }, error = function(error) {

      msg <- paste0(task_title, " Error")


      # print `msg` so that we can find it in the logs
      print(msg)
      # print the actual error to log it
      print(error)
      # show error `msg` to user.  User can then tell us about error and we can
      # quickly identify where it cam from based on the value in `msg`
      showToast("error", msg)
    })
  })

}
