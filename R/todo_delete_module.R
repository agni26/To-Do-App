
#' todo Delete Module
#'
#' This module is for deleting a row's information from the todo database file
#'
#' @importFrom shiny observeEvent req showModal h3 modalDialog removeModal actionButton modalButton
#' @importFrom DBI dbExecute
#' @importFrom shinyFeedback showToast
#'
#' @param task_title string - the title for the modal
#' @param task_to_delete string - the model of the car to be deleted
#' @param modal_trigger reactive trigger to open the modal (Delete button)
#'
#' @return None
#'
todo_delete_module <- function(input, output, session, task_title, task_to_delete, modal_trigger) {
  ns <- session$ns
  # Observes trigger for this module (here, the Delete Button)
  observeEvent(modal_trigger(), {
    # Authorize who is able to access particular buttons (here, modules)
    req(session$userData$email == 'tycho.brahe@tychobra.com')

    showModal(
      modalDialog(
        div(
          style = "padding: 30px;",
          class = "text-center",
          h2(
            style = "line-height: 1.75;",
            paste0(
              'Are you sure you want to delete the "',
              task_to_delete()$model,
              '"?'
            )
          )
        ),
        title = task_title,
        size = "m",
        footer = list(
          modalButton("Cancel"),
          actionButton(
            ns("submit_delete"),
            "Delete todo",
            class = "btn-danger",
            style="color: #fff;"
          )
        )
      )
    )
  })

  observeEvent(input$submit_delete, {
    req(task_to_delete())

    removeModal()

    tryCatch({

      uid <- task_to_delete()$uid

      DBI::dbExecute(
        con,
        "DELETE FROM todo WHERE uid=$1",
        params = c(uid)
      )

      session$userData$todo_trigger(session$userData$todo_trigger() + 1)
      showToast("success", "todo Successfully Deleted")
    }, error = function(error) {

      msg <- "Error Deleting todo"
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
