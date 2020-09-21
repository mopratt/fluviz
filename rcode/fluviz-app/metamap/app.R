library(shiny)
ui <-  fluidPage(
  tags$h1("fluviz"), 
  tags$h4("Visualization of Influenza Sequences and Metadata"),
  fluidRow(
    column(6,
           textInput(inputId = "tree", 
            label = "Name of Tree Object:")),
    column(6, 
           textInput(inputId = "meta", 
                     label = "Metadata Object:")),
    ),
  fluidRow(
    column(2, offset = 5, 
           actionButton(inputId = "submit", label = "Submit"))
  ),
  fluidRow(
    column(10, 
           checkboxGroupInput(inputId = "choose",
                              label = "Choose Columns:", 
                              choices = c("Clade", "Subtype", "Host"), 
                              selected = "Clade", 
                              inline = TRUE))
  ),
  fluidRow(
    column(2, offset = 5,
           actionButton(inputId = "go", label = "Plot"))
  ),
  fluidRow(
    column(12, 
           plotOutput("metamap"))
  )
)
server <- function(input, output, session) {
  library(ggplot2)
  library(tidyverse)
  library(ggnewscale)
  library(plotly)
  library(ggtree)
  library(treeio)
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
                             label = "Choose Columns:", 
                             choices = cols(), 
                             selected = "Clade", 
                             inline = TRUE)
  })
  choices <- eventReactive(input$choose, {
    input$choose
  })
  metamap <- function(tree, metadata, cols = "Clade") {
    met <- metadata %>% select(cols) %>% data.frame()
    treet <- tree %>% as.phylo() %>% as_tibble()
    treet_data <- treet %>% left_join(metadata, by = 'label')
    tree <- as.treedata(treet_data) %>% ggtree(branch.length = "none") + geom_tiplab(size = 2)
    rownames(met) <- metadata$label # metadata file must have first column as labels
    low = "red"
    high = "green"
    for (i in colnames(met)) {
      assign(paste0(i, ".df"), select(met, i))}
    for (i in colnames(met)) {
      if (i == first(colnames(met))) {
        h = 1
        ofs = 3
        let = 4
        x = 26.5
        if (is(get(paste0(i, ".df"))[,1], "numeric")) {
          assign(paste0("h", h), gheatmap(tree, get(paste0(i, ".df")),
                                          offset = ofs, width = 0.1, 
                                          colnames_position = "top", 
                                          colnames_offset_y = 1, 
                                          font.size = 3) +
                   scale_fill_gradient(low = low, high = high, na.value = NA, name = i))
        } else {
          assign(paste0("h", h), gheatmap(tree, get(paste0(i, ".df")),
                                          offset = ofs, width = 0.1, 
                                          colnames_position = "top", 
                                          colnames_offset_y = 1, 
                                          font.size = 3) +
                   scale_fill_viridis_d(option = LETTERS[let], name = i))
        }
      } else {
        h = h + 1
        assign((paste0("h", h)), get(paste0("h", h - 1)) + new_scale_fill())
        h = h + 1
        ofs = ofs + 2
        let = if_else(let == 1, 4, let - 1)
        x = x + 6
        if (is(get(paste0(i, ".df"))[,1], "numeric")) {
          assign(paste0("h", h), gheatmap(get(paste0("h", h - 1)), get(paste0(i, ".df")), 
                                          offset = ofs, width = 0.1,
                                          colnames_position = "top", 
                                          colnames_offset_y = 1, 
                                          font.size = 3) +
                   scale_fill_gradient(low = low, high = high, na.value = NA, name = i))
        }
        else {
          assign(paste0("h", h), gheatmap(get(paste0("h", h - 1)), get(paste0(i, ".df")), 
                                          offset = ofs, width = 0.1,
                                          colnames_position = "top", 
                                          colnames_offset_y = 1, 
                                          font.size = 3) +
                   scale_fill_viridis_d(option = LETTERS[let], name = i))
        }
      }
    }
    get(paste0("h", h)) + theme(legend.position = "bottom") + coord_cartesian(clip = "off")
  }
  map <- eventReactive(input$go, {
    metamap(tree = tree(), metadata = metadata(), 
            cols = choices()) +
      theme(legend.position = "right")
  })
  output$metamap <- renderPlot({map()})
  }

shinyApp(ui = ui, server = server)
