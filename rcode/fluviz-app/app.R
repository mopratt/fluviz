library(shiny)
library(knitr)
library(ggplot2)
library(tidyverse)
library(ggnewscale)
library(plotly)
library(ggtree)
library(treeio)
library(readxl)
library(readr)

source("fn_combine_metadata_shiny.R")
source("fn_metamap.R")
source("fn_snpplot.R")

ui <-  navbarPage(title = "fluviz", 
             tabPanel(title = "Introduction", 
                      tags$h1("fluviz"), 
                      tags$h4("Visualization of Influenza Sequences and Metadata"), 
                      includeMarkdown("README.md")
                      ),
             tabPanel(title = "combine metadata", 
                      sidebarLayout(
                        sidebarPanel(
                          wellPanel(
                            fluidRow(
                              fileInput(inputId = "mxls", 
                                               label = "GISAID metadata Excel file:", 
                                               accept = c(".xls", ".xlsx")), 
                              fileInput(inputId = "llcsv", 
                                               label = "Line List CSV file:", 
                                               accept = ".csv"), 
                              selectInput(inputId = "label", 
                                                 label = "Select which column contains sequence labels:", 
                                                 c("Isolate_Name", "Isolate_Id")
                                     )
                            ),
                            fluidRow(
                              actionButton(inputId = "upload", label = "Combine Metadata"))
                            )
                        ),
                        mainPanel(
                          dataTableOutput("data")
                        )
                      )),
             tabPanel(title = "import phylogenetic tree", 
                      sidebarLayout(
                        sidebarPanel(tags$h3("import a phylogenetic tree using treeio"),
                                     tags$em("if your file type is not listed here see the Tutorial section for more information"),
                          wellPanel(
                            fileInput(inputId = "phyl", label = "Phylogenetic tree file:", 
                                      accept = c(".nhx", ".nwk", ".nexus")), 
                            selectInput(inputId = "ext", 
                                        label = "Select the type of tree file you are using:", 
                                        c("Newick: .nwk" = "nwk",
                                          "Nexus: .nexus" = "nexus",
                                          "New Hampshire: .nhx" = "nhx")),
                           actionButton(inputId = "ggtree", label = "Generate Tree") 
                          ),
                        width = 4), 
                        mainPanel(
                          wellPanel(
                            plotOutput("phylo")
                          ),
                        width = 8)
                      )),
             tabPanel(title = "plot metadata heatmap",
                      sidebarLayout(
                        sidebarPanel(
                          wellPanel(
                            fluidRow(
                              actionButton(inputId = "auto", label = "Load my data")
                          )
                          ),
                          wellPanel(fluidRow(
                            checkboxGroupInput(inputId = "choose",
                                                      label = "Choose columns to plot:", 
                                                      choices = c("Clade", "Subtype", "Host"), 
                                                      selected = "Clade")
                          ),
                          fluidRow(
                            actionButton(inputId = "go", label = "Plot")
                          ))),
                        mainPanel(
                          fluidRow(
                            plotOutput("metamap")
                            )
                          )
                        )
                      ),
             tabPanel(title = "interactive snpplot")
  )
server <- function(input, output, session) {
  my_data <- eng_meta_clean
  my_tree <- tree_eng
  
  gisaid <- eventReactive(input$upload, {
    excel <- input$mxls
    excel$datapath
  })
  linelist <- eventReactive(input$upload, {
    csv <- input$llcsv
    csv$datapath
  })
  label <- eventReactive(input$upload, {
    input$label
  })
  mdata <- eventReactive(input$upload, {
    combine_metadata_shiny(metadata = gisaid(), 
                           line_list = linelist(),
                           label_col = label())
  })
  output$data <- renderDataTable({mdata()})
  
  phylo <- eventReactive(input$ggtree, {
    phyl <- input$phyl
    phyl$datapath
  })
  tree1 <- eventReactive(input$ggtree, {
    getFunction(paste0("read.", input$ext))((phylo()))
  })
  output$phylo <- renderPlot({
    as.phylo(tree1()) %>% ggtree(branch.length = "none") +
      geom_tiplab(size=3) + ggplot2::xlim(0,17)
  })
  cols <- eventReactive(input$auto, {
    names(mdata())
  })
  observeEvent(input$auto, {
    updateCheckboxGroupInput(session, "choose", 
                             label = "Choose columns from your data to plot:", 
                             choices = cols(), 
                             selected = "Clade")
  })
  choices <- eventReactive(input$choose, {
    input$choose
  })
  map <- eventReactive(input$go, {
    metamap(tree = tree1(), metadata = mdata(), 
            cols = choices())
  })
  output$metamap <- renderPlot({map()}, width = 1500, height = 1000)
  }

shinyApp(ui = ui, server = server)
