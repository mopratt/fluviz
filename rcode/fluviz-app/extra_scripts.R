# In UI:
helpText("OR you can upload other objects from R"),
textInput(inputId = "tree", 
          label = "Name of Tree Object in R:"),
textInput(inputId = "meta", 
          label = "Name of Metadata Object in R:")
),
fluidRow(
  actionButton(inputId = "submit", label = "Submit")
# In server function:
tree <- eventReactive(input$submit, {
  get(as.character(input$tree))
})
metadata <- eventReactive(input$submit, {
  get(as.character(input$meta))
})
cols <- eventReactive(input$submit, {
  unique(names(get(as.character(input$meta))))
})
observeEvent(input$submit, {
  updateCheckboxGroupInput(session, "choose", 
                           label = "Choose columns from the data to plot:", 
                           choices = cols(), 
                           selected = "Clade")
})