function get_id(clicked_id) {
     Shiny.setInputValue("add-current_id", clicked_id, {priority: "event"});
}